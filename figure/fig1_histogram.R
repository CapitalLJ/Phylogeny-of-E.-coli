# Rscript fig1_histogram.R

library(ggplot2)

data <- read.table("Duplication_distribution.tsv", header = TRUE, sep = "\t", check.names = FALSE)
subdata1 <- subset(data, Number <= 1 )
subdata2 <- subset(data, Number >= 2 & Number <= 5)
subdata3 <- subset(data, Number >= 6 & Number <= 92)
subdata4 <- subset(data, Number >= 108 & Number <= 970)

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

# Histogram - subdata1
histogram1 <- ggplot(subdata1, aes(x = as.factor(Number), y = Frequency, fill = Phylogroup)) +
    geom_bar(stat = "identity") + 
    scale_y_continuous(expand = c(0, 0), limits = c(0, 25000), breaks = seq(0, 25000, by = 5000)) +
    scale_fill_manual(values = group_colors) +
    theme_minimal() + 
    labs(x = "Count", y = "Frequency") +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 7, face = "bold"),
        axis.text.y = element_text(size = 7, face = "bold"), 
        axis.title = element_text(size = 9, face = "bold"),
        legend.title = element_text(size = 9, face = "bold"),
        legend.text = element_text(size = 7, face = "bold"),
        panel.grid = element_blank(),
        axis.line.y = element_line(colour = "black", linewidth = 0.2),
        axis.ticks.y = element_line(colour = "black", linewidth = 0.2),
        axis.ticks.length = unit(1.2, "mm")
    ) +
    guides(
        fill = guide_legend(keyheight = 0.8, keywidth = 0.8)
    )

ggsave("subdata1.png", plot = histogram1, width = 120, height = 120, units = "mm")
ggsave("subdata1.eps", plot = histogram1, width = 120, height = 120, units = "mm")

# Histogram - subdata2
histogram2 <- ggplot(subdata2, aes(x = as.factor(Number), y = Frequency, fill = Phylogroup)) +
    geom_bar(stat = "identity") + 
    scale_y_continuous(expand = c(0, 0), limits = c(0, 4000), breaks = seq(0, 4000, by = 1000)) +
    scale_fill_manual(values = group_colors) +
    theme_minimal() + 
    labs(x = "Count", y = "Frequency") +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 7, face = "bold"),
        axis.text.y = element_text(size = 7, face = "bold"), 
        axis.title = element_text(size = 9, face = "bold"),
        legend.title = element_text(size = 9, face = "bold"),
        legend.text = element_text(size = 7, face = "bold"),
        panel.grid = element_blank(),
        axis.line.y = element_line(colour = "black", linewidth = 0.2),
        axis.ticks.y = element_line(colour = "black", linewidth = 0.2),
        axis.ticks.length = unit(1.2, "mm")
    ) +
    guides(
        fill = guide_legend(keyheight = 0.8, keywidth = 0.8)
    )

ggsave("subdata2.png", plot = histogram2, width = 120, height = 120, units = "mm")
ggsave("subdata2.eps", plot = histogram2, width = 120, height = 120, units = "mm")

# Histogram - subdata3
histogram3 <- ggplot(subdata3, aes(x = as.factor(Number), y = Frequency, fill = Phylogroup)) +
    geom_bar(stat = "identity") + 
    scale_y_continuous(expand = c(0, 0), limits = c(0, 500), breaks = seq(0, 500, by = 100)) +
    scale_fill_manual(values = group_colors) +
    theme_minimal() + 
    labs(x = "Count", y = "Frequency") +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 7, face = "bold"),
        axis.text.y = element_text(size = 7, face = "bold"), 
        axis.title = element_text(size = 9, face = "bold"),
        legend.title = element_text(size = 9, face = "bold"),
        legend.text = element_text(size = 7, face = "bold"),
        panel.grid = element_blank(),
        axis.line.y = element_line(colour = "black", linewidth = 0.2),
        axis.ticks.y = element_line(colour = "black", linewidth = 0.2),
        axis.ticks.length = unit(1.2, "mm")
    ) +
    guides(
        fill = guide_legend(keyheight = 0.8, keywidth = 0.8)
    )

ggsave("subdata3.png", plot = histogram3, width = 120, height = 120, units = "mm")
ggsave("subdata3.eps", plot = histogram3, width = 120, height = 120, units = "mm")

# Histogram - subdata4
histogram4 <- ggplot(subdata4, aes(x = as.factor(Number), y = Frequency, fill = Phylogroup)) +
    geom_bar(stat = "identity") + 
    scale_y_continuous(expand = c(0, 0), limits = c(0, 1000), breaks = seq(0, 1000, by = 200)) +
    scale_fill_manual(values = group_colors) +
    theme_minimal() + 
    labs(x = "Count", y = "Frequency") +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 7, face = "bold"),
        axis.text.y = element_text(size = 7, face = "bold"), 
        axis.title = element_text(size = 9, face = "bold"),
        legend.title = element_text(size = 9, face = "bold"),
        legend.text = element_text(size = 7, face = "bold"),
        panel.grid = element_blank(),
        axis.line.y = element_line(colour = "black", linewidth = 0.2),
        axis.ticks.y = element_line(colour = "black", linewidth = 0.2),
        axis.ticks.length = unit(1.2, "mm")
    ) +
    guides(
        fill = guide_legend(keyheight = 0.8, keywidth = 0.8)
    )

ggsave("subdata4.png", plot = histogram4, width = 120, height = 120, units = "mm")
ggsave("subdata4.eps", plot = histogram4, width = 120, height = 120, units = "mm")