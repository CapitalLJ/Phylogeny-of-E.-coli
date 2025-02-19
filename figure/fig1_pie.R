# Rscript fig1_pie.R MultPcr_All_40472.tsv phylogroup_before
# Rscript fig1_pie.R MultPcr_Rep_27377.tsv phylogroup_after

library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
multpcr_phylogroup_file <- args[1]
pie_name <- args[2]

# Defind Colors
group_colors <- c(
    "A" = "#4874cb", 
    "B1" = "#ee822f", 
    "B2" = "#f2ba02", 
    "C" = "#75bd42", 
    "D" = "#30c0b4",
    "E" = "#e54c5e", 
    "F" = "#254380", 
    "G" = "#9e4c0d", 
    "others" = "#467128", 
    "Shig" = "#917001"
)

# Count phylogroup percentage
count_phylogroup_percentage <- function(multpcr_phylogroup_file) {
    df <- read.table(multpcr_phylogroup_file, sep = "\t", header = FALSE)

    phylo_counts <- as.data.frame(table(df$V2))
    colnames(phylo_counts) <- c("phylogroup", "count")
    phylo_counts$percentage <- (phylo_counts$count / sum(phylo_counts$count)) * 100

    return(phylo_counts)
}

count_data <- count_phylogroup_percentage(multpcr_phylogroup_file)

# Pie
pie <- ggplot(count_data, aes(x = "", y = percentage, fill = phylogroup)) +
    geom_bar(stat = "identity") +  # Histogram
    coord_polar(theta = "y") + # Histogram to Pie
    scale_fill_manual(values = group_colors) +
    theme_void() + 
    theme(
        legend.position = "right",
        legend.title = element_text(size = 9, face = "bold"),
        legend.text = element_text(size = 7, face = "bold"),
        )  +
    guides(
        fill = guide_legend(keyheight = 0.8, keywidth = 0.8)
    ) +
    labs(fill = "Phylogroup")


# print(count_data)

ggsave(paste0(pie_name, ".png"), plot = pie, width = 140, height = 120, units = "mm")
ggsave(paste0(pie_name, ".eps"), plot = pie, width = 140, height = 120, units = "mm")