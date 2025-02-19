# Rscript fig1_histogram_data.R All_ecoli_cluster.tsv MultPcr_All_40472.tsv

args <- commandArgs(trailingOnly = TRUE)
cluster_file <- args[1]
multpcr_phylogroup_file <- args[2]

count_cluster_element_numbers <- function(cluster_file, multpcr_phylogroup_file) {
    lines <- readLines(cluster_file)
    
    result_list <- vector("list", length(lines))
    index <- 1

    for (i in seq_along(lines)) {
        columns <- strsplit(lines[i], "\t")[[1]]
        column_count <- length(columns)

        for (col in columns) {
            result_list[[index]] <- data.frame(Number = column_count, ID = col, stringsAsFactors = FALSE)
            index <- index + 1
        }
    }

    result_list <- result_list[!sapply(result_list, is.null)]
    result_df <- do.call(rbind, result_list)

    phylogroup_df <- read.table(multpcr_phylogroup_file, sep = "\t", header = FALSE, stringsAsFactors = FALSE)
    colnames(phylogroup_df) <- c("ID", "Phylogroup")

    merged_df <- merge(result_df, phylogroup_df, by = "ID", all.x = TRUE)

    return(merged_df)
}

result <- count_cluster_element_numbers(cluster_file, multpcr_phylogroup_file)
summary <- as.data.frame(table(result$Number, result$Phylogroup))
colnames(summary) <- c("Number", "Phylogroup", "Frequency")

write.table(summary, "Duplication_distribution.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
