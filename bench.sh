#!/usr/bin/env bash

# ── args ──────────────────────────────────────────────────────────────────────
ITERS=100
OUT="$HOME/bench_results.csv"
REPO=""

usage() {
    echo "Usage: $0 --repo PATH [--iters N] [--out PATH]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo)  REPO="$2";  shift 2 ;;
        --iters) ITERS="$2"; shift 2 ;;
        --out)   OUT="$2";   shift 2 ;;
        *) usage ;;
    esac
done

# ── validation ────────────────────────────────────────────────────────────────
[[ -z "$REPO" ]]   && { echo "[ERROR] --repo required"; usage; }
[[ ! -d "$REPO" ]] && { echo "[ERROR] not a directory: $REPO"; exit 1; }
[[ "$ITERS" -lt 1 ]] 2>/dev/null || true
if ! [[ "$ITERS" =~ ^[0-9]+$ ]]; then
    echo "[ERROR] --iters must be a positive integer"; exit 1
fi

# ── purr check ────────────────────────────────────────────────────────────────
PURR_OK=true
command -v purr &>/dev/null || { echo "[WARN] purr not in PATH — purr_ms will be N/A"; PURR_OK=false; }

# ── out file ──────────────────────────────────────────────────────────────────
mkdir -p "$(dirname "$OUT")"
HEADER="run_id,iteration,repo,file_count,git_ms,purr_ms,timestamp"

if [[ -f "$OUT" ]]; then
    echo "[WARN] File exists: $OUT"
    echo "  1) Delete it and recreate"
    echo "  2) Append to it"
    echo "  3) Abort the call"
    while true; do
        read -r -p "Enter choice [1-3]: " CHOICE < /dev/tty
        case "$CHOICE" in
            1)
                rm -f "$OUT"
                echo "$HEADER" > "$OUT"
                break
                ;;
            2)
                if [[ ! -s "$OUT" ]]; then
                    echo "$HEADER" > "$OUT"
                fi
                break
                ;;
            3)
                echo "[INFO] Aborting call."
                exit 1
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
else
    echo "$HEADER" > "$OUT"
fi

# ── prep ──────────────────────────────────────────────────────────────────────
RUN_ID=$(date +%Y%m%d_%H%M%S)
cd "$REPO"

# count files once — exclude vcs dirs, consistent across iters
FILE_COUNT=$(find . \
    -not -path './.git/*' \
    -not -path './.purr/*' \
    -not -name '.git' \
    -not -name '.purr' \
    -type f | wc -l | tr -d ' ')

echo "[INFO] run_id    : $RUN_ID"
echo "[INFO] repo      : $REPO"
echo "[INFO] files     : $FILE_COUNT"
echo "[INFO] iters     : $ITERS"
echo "[INFO] out       : $OUT"
echo "[INFO] purr      : $PURR_OK"
[[ -d ".git"  ]] && echo "[WARN] .git exists — will be destroyed each iteration"
[[ -d ".purr" ]] && echo "[WARN] .purr exists — will be destroyed each iteration"
echo ""

# ── interrupt: flush partial row ──────────────────────────────────────────────
trap '
    echo ""
    echo "[INTERRUPTED] flushing marker to CSV"
    echo "${RUN_ID},INTERRUPTED,${REPO},${FILE_COUNT},,,$(date +%Y-%m-%dT%H:%M:%S)" >> "$OUT"
    rm -rf .git .purr
    exit 130
' SIGINT SIGTERM

# ── benchmark loop ────────────────────────────────────────────────────────────
for i in $(seq 1 "$ITERS"); do

    # clean slate
    rm -rf .git .purr

    # reinit both
    git init -q
    $PURR_OK && purr init > /dev/null 2>&1

    TS=$(date +%Y-%m-%dT%H:%M:%S)

    # git add
    T1=$(date +%s%N)
    git add . > /dev/null 2>&1
    T2=$(date +%s%N)
    GIT_MS=$(( (T2 - T1) / 1000000 ))

    # purr add
    if $PURR_OK; then
        T3=$(date +%s%N)
        purr add . > /dev/null 2>&1
        T4=$(date +%s%N)
        PURR_MS=$(( (T4 - T3) / 1000000 ))
    else
        PURR_MS="N/A"
    fi

    ROW="${RUN_ID},${i},${REPO},${FILE_COUNT},${GIT_MS},${PURR_MS},${TS}"
    echo "$ROW" | tee -a "$OUT"
done

# ── cleanup ───────────────────────────────────────────────────────────────────
rm -rf .git .purr
echo ""
echo "[DONE] $ITERS iterations → $OUT"
