# Changelog

## 1.0.0

First public release of the template.

- Simplified structure: `main.nf` -> subworkflow (`workflows/`) -> processes (`modules/`)
- Example scatter/gather analysis: per-sample summary (`SUMMARISE_SAMPLE`) and HTML report (`REPORT`)
- `test` and `test_full` profiles using only data shipped in `testdata/`, so they run without
  access to external buckets or the internet (only the container registry is needed)
- Executor-specific settings selected automatically from `--lifebit_platform_executor`
  (`conf/cloud-provider.config`), with one Azure Batch pool per resource label
- Containers declared in a single file (`conf/containers.config`) with pinned tags
- Code compatible with Nextflow `>=22.10.0` and with the strict syntax checked by `nextflow lint`
