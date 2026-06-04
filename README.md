# persephone-bench

Benchmarks `git add` vs `purr add` staging time across iterations and saves to CSV.

> [!WARNING]
> Destroys & recreates `.git`/`.purr` in target repo. Don't run on working repos.

## Usage

`./bench.sh --repo PATH [--iters N] [--out PATH]`

- `--repo`: Repo directory to benchmark (required)
- `--iters`: Iterations (default: 100)
- `--out`: CSV output path (default: `~/bench_results.csv`)

## Results Mapping

| Result File                              | Commit                                                                                               | Repo       | Files | Iters | git (avg/min/max) | purr (avg/min/max) | Date (DD-MM-YYYY) |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------- | ---------- | ----- | ----- | ----------------- | ------------------ | ----------------- |
| [results_V1.csv](Results/results_V1.csv) | [dbd0262](https://github.com/TheRealShek/persephone/commit/dbd02627583ea636a2b762f5f08cab9ea3dedef0) | prometheus | 1619  | 500   | 278/258/360       | 213/186/290        | 04-06-2026        |
| [results_V2.csv](Results/results_V2.csv) | [ff93181](https://github.com/TheRealShek/persephone/commit/ff9318163c9779a53b74828d9a5d9fce33654c45) | prometheus | 1619  | 500   | 289.3/267/347     | 150.6/136/197      | 04-06-2026        |

## Output Format

`run_id,iteration,repo,file_count,git_ms,purr_ms,timestamp`

Each iteration wipes `.git`/`.purr`, runs init & add, and measures duration in ms.
