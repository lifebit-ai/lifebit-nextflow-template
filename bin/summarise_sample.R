#!/usr/bin/env Rscript
# Usage: summarise_sample.R <sample_id> <counts.csv> <output.csv>
#
# Reads a CSV with the columns 'gene' and 'count' and writes a one-row summary.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
    stop("Usage: summarise_sample.R <sample_id> <counts.csv> <output.csv>")
}
sample_id <- args[1]
counts    <- read.csv(args[2], stringsAsFactors = FALSE)

if (!all(c("gene", "count") %in% colnames(counts))) {
    stop("The counts file must contain the columns 'gene' and 'count'")
}

summary <- data.frame(
    sample         = sample_id,
    genes          = nrow(counts),
    genes_detected = sum(counts$count > 0),
    total_counts   = sum(counts$count),
    median_count   = median(counts$count),
    top_gene       = counts$gene[which.max(counts$count)]
)

write.csv(summary, args[3], row.names = FALSE)
