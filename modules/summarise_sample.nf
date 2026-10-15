/*
    Compute summary statistics for one sample.

    input:  [ sample_id, counts.csv ]   CSV with the columns 'gene' and 'count'
    output: [ sample_id, <sample_id>.summary.csv ]

    Scripts in bin/ are added to the PATH of every task, so they can be called directly.
*/
process SUMMARISE_SAMPLE {
    tag "${sample_id}"
    label 'process_low'
    publishDir "${params.outdir}/summaries", mode: 'copy'

    input:
    tuple val(sample_id), path(counts)

    output:
    tuple val(sample_id), path("${sample_id}.summary.csv"), emit: summary

    script:
    """
    summarise_sample.R ${sample_id} ${counts} ${sample_id}.summary.csv
    """
}
