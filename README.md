# persephone-bench

Benchmarks **`git add`** vs **`purr add`** on a target repo, measuring staging time across repeated iterations and writing results to CSV.

> [!WARNING]
> The script **destroys and recreates** `.git` and `.purr` inside the target repo each iteration. Don't point it at a repo you care about.

## Usage

```bash
./bench.sh --repo PATH [--iters N] [--out PATH]
```

| Flag | Default | Description |
|------|---------|-------------|
| `--repo` | *(required)* | Repository directory to benchmark |
| `--iters` | `100` | Number of init→add→measure iterations |
| `--out` | `~/bench_results.csv` | Output CSV path (created if missing) |

## Output

```
run_id,iteration,repo,file_count,git_ms,purr_ms,timestamp
```

Each iteration: wipes `.git`/`.purr` → reinitializes both → times `git add .` and `purr add .` (nanosecond precision, reported in ms) → appends a row. If `purr` isn't installed, `purr_ms` is recorded as `N/A`. On `SIGINT`/`SIGTERM`, an `INTERRUPTED` marker row is flushed before cleanup.

**Requires**: bash ≥ 4, git, coreutils. **Optional**: purr.
