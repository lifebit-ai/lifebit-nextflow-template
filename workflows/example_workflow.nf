/*
========================================================================================
    EXAMPLE_WORKFLOW
========================================================================================
    A subworkflow groups processes into a reusable unit with a clear interface:
      take: the channels it receives
      emit: the channels it returns to the caller

    This example shows the most common pattern, scatter -> gather:
      1. SUMMARISE_SAMPLE runs once per sample (in parallel)
      2. the per-sample results are merged into a single table
      3. REPORT runs once on the merged table
----------------------------------------------------------------------------------------
*/

include { SUMMARISE_SAMPLE } from '../modules/summarise_sample'
include { REPORT           } from '../modules/report'

workflow EXAMPLE_WORKFLOW {

    take:
    ch_samples      // channel: [ val(sample_id), path(counts) ]

    main:
    // Files shipped with the pipeline are staged by Nextflow like any other input
    ch_report_rmd = channel.value(file("${projectDir}/assets/report/report.Rmd", checkIfExists: true))
    ch_logo       = channel.value(file("${projectDir}/assets/report/logo.png", checkIfExists: true))

    SUMMARISE_SAMPLE(ch_samples)

    ch_merged_summary = SUMMARISE_SAMPLE.out.summary
        .map { _sample_id, summary -> summary }
        .collectFile(name: 'all_samples_summary.csv', keepHeader: true, skip: 1, sort: { f -> f.name })

    REPORT(ch_merged_summary, ch_report_rmd, ch_logo)

    emit:
    summary = SUMMARISE_SAMPLE.out.summary  // channel: [ val(sample_id), path(summary_csv) ]
    report  = REPORT.out.report             // channel: path(report_html)
}
