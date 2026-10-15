/*
    Render an HTML report from the merged summary table.

    input:  summary.csv   merged table with one row per sample
            report_rmd    R Markdown template (assets/report/report.Rmd)
            logo          image used by the template (assets/report/logo.png)
    output: report.html
*/
process REPORT {
    label 'process_low'
    publishDir "${params.outdir}/report", mode: 'copy'

    input:
    path summary
    path report_rmd
    path logo

    output:
    path "report.html", emit: report

    script:
    """
    Rscript -e "rmarkdown::render('${report_rmd}', output_file = 'report.html', params = list(summary = '${summary}'))"
    """
}
