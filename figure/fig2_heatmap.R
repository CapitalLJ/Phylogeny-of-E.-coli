# Rscript fig2_heatmap.R Rep_mash_distance.csv MultPcr_Rep_27377.tsv mash_heatmap
# Rscript fig2_heatmap.R Rep_bac120_distance.csv MultPcr_Rep_27377.tsv bac120_heatmap
# Rscript fig2_heatmap.R Rep_f88_distance.csv MultPcr_Rep_27377.tsv f88_heatmap

library(gplots)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)
distance_matrix_file <- args[1]
multpcr_phylogroup_file <- args[2]
heatmap_name <- args[3]

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

# distance matrix
distance_matrix <- as.matrix(read.csv(distance_matrix_file, sep = ',', header = TRUE, row.names = 1))

# Generate dist object and cluster
dist <- as.dist(distance_matrix)
hc <- hclust(dist, method = 'ward.D2')

# phylogroup group
phylogroup_data <- read.table(multpcr_phylogroup_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

# Color mapping
ordered_phylogroup <- phylogroup_data$V2[match(rownames(distance_matrix), phylogroup_data$V1)]
group_factor <- factor(ordered_phylogroup, levels = names(group_colors))
phyl_colors <- group_colors[group_factor]

png(paste0(heatmap_name, ".png"), units = 'in', width = 20, height = 20, res = 600)

heatmap <- heatmap.2(distance_matrix,
    Rowv = rev(as.dendrogram(hc)),
    Colv = as.dendrogram(hc),
    dendrogram = "column",

    col = colorRampPalette(rev(brewer.pal(n = 11, name = "BrBG")))(200),
    scale = "none",
    labRow = FALSE,
    labCol = FALSE,
    ColSideColors = phyl_colors,
    trace = "none",
    key = FALSE
)

dev.off()

