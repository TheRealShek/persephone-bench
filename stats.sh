#!/usr/bin/env bash

CSV="$1"

[[ -z "$CSV" ]]   && { echo "[ERROR] usage: $0 <path-to-csv>"; exit 1; }
[[ ! -f "$CSV" ]] && { echo "[ERROR] file not found: $CSV"; exit 1; }

awk -F',' '
NR==1 { next }  # skip header
$5 == "INTERRUPTED" || $5 == "" { next }  # skip bad rows

{
    git=$5; purr=$6

    # git
    git_sum += git; git_count++
    if (git_min == "" || git < git_min) git_min = git
    if (git > git_max) git_max = git

    # purr — skip N/A
    if (purr != "N/A" && purr != "") {
        purr_sum += purr; purr_count++
        if (purr_min == "" || purr < purr_min) purr_min = purr
        if (purr > purr_max) purr_max = purr
    }
}

END {
    printf "\n%-10s %10s %10s %10s\n", "command", "avg_ms", "min_ms", "max_ms"
    printf "%-10s %10s %10s %10s\n", "-------", "------", "------", "------"

    if (git_count > 0)
        printf "%-10s %10.1f %10d %10d\n", "git add", git_sum/git_count, git_min, git_max

    if (purr_count > 0)
        printf "%-10s %10.1f %10d %10d\n", "purr add", purr_sum/purr_count, purr_min, purr_max

    printf "\nrows counted: git=%d purr=%d\n\n", git_count, purr_count
}
' "$CSV"
