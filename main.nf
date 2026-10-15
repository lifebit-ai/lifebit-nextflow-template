#!/usr/bin/env nextflow
/*
========================================================================================
    subworkflow-template-nf
========================================================================================
    Entry point of the pipeline. It is responsible for:
      1. validating the parameters
      2. turning the samplesheet (--input) into a channel
      3. calling the subworkflow(s) that do the actual analysis

    Keep the analysis logic in workflows/ and modules/, so that this file stays short.
----------------------------------------------------------------------------------------
*/

include { EXAMPLE_WORKFLOW } from './workflows/example_workflow'


def helpMessage() {
    return """
    Usage:
        nextflow run main.nf --input samplesheet.csv --outdir results -profile docker

    Mandatory arguments:
        --input     CSV samplesheet with the columns 'sample' and 'counts' (see README.md)

    Optional arguments:
        --outdir    Directory where the results are published (default: ${params.outdir})
        --help      Print this message and exit

    Test profiles (no input needed):
        -profile test,docker
        -profile test_full,docker
    """.stripIndent()
}

/*
 * Resolve a file path read from the samplesheet.
 * Absolute paths and URIs (s3://, az://, gs://, https://) are used as they are,
 * relative paths are resolved against the folder containing the samplesheet.
 */
def resolvePath(String path, samplesheetDir) {
    def f = path.startsWith('/') || path.contains('://') ? file(path) : samplesheetDir.resolve(path)
    if (!f.exists()) error "File not found: ${f.toUriString()}"
    return f
}


workflow {

    if (params.help) {
        log.info helpMessage()
        exit(0)
    }

    if (!params.input) {
        error "Missing mandatory parameter --input. Run with --help for usage."
    }

    log.info """
    ${workflow.manifest.name} v${workflow.manifest.version}
    ----------------------------------------------------
    input      : ${params.input}
    outdir     : ${params.outdir}
    profile    : ${workflow.profile}
    workDir    : ${workflow.workDir}
    ----------------------------------------------------
    """.stripIndent()

    /*
     * Samplesheet -> channel of [ sample_id, counts_file ]
     */
    def samplesheet = file(params.input, checkIfExists: true)

    ch_samples = channel
        .fromPath(samplesheet)
        .splitCsv(header: true)
        .map { row ->
            if (!row.sample || !row.counts) {
                error "Invalid samplesheet row ${row}: the columns 'sample' and 'counts' are mandatory."
            }
            tuple(row.sample, resolvePath(row.counts, samplesheet.parent))
        }
        .toList()
        .map { rows ->
            def ids = rows.collect { row -> row[0] }
            if (ids.size() != ids.unique(false).size()) {
                error "Invalid samplesheet: sample IDs must be unique."
            }
            rows
        }
        .flatMap()

    EXAMPLE_WORKFLOW(ch_samples)
}
