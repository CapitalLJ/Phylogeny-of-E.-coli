library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(gplots)
library(pheatmap)
library(sparcl)
library(MASS)

# 解析命令行参数
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 3) {
  stop("Usage: Rscript generate_heatmap.R <distance_matrix.csv> <output_image_prefix> <output_matrix_prefix>")
}

# 从命令行读取输入文件和输出文件前缀
distance_matrix_file <- args[1]
output_image_prefix <- args[2]
output_matrix_prefix <- args[3]
colfunc <- colorRampPalette(rev(brewer.pal(n=11, name = "BrBG")))

# 读取距离矩阵数据
distance_matrix <- as.matrix(read.csv(distance_matrix_file, sep = ',', header = TRUE, row.names = 1))

# 创建距离矩阵和层次聚类
dis_e_mash <- as.dist(distance_matrix)
hc_e_mash <- hclust(dis_e_mash, method = 'ward.D2')

# 生成热图文件路径
heatmap_fp <- paste0(output_image_prefix, "_heatmap.png")

# 保存热图为 PNG 文件
png(heatmap_fp, units = 'in', width = 30, height = 15, res = 360)
heatmap(distance_matrix,
        Rowv = as.dendrogram(hc_e_mash),
        Colv = 'Rowv',
        col = colorRampPalette(rev(brewer.pal(n = 11, name = "BrBG")))(200000),
        scale = 'none',
        labRow = FALSE,
        labCol = FALSE)
dev.off()

hc_e_mash$height <- sort(hc_e_mash$height)


dendro_fp_900 <- paste0(output_image_prefix, "_dendrogram_900.png")

mcl_e2 <- cutree(hc_e_mash, h = max(hc_e_mash$height * 9E-02))

png(dendro_fp_900, units = "in", width = 30, height = 15, res = 360)
ColorDendrogram(hc_e_mash, y = mcl_e2, branchlength = 20)
dev.off()
# ====================================================
# 保存分组和标签矩阵（175）
group_fp_175 <- paste0(output_matrix_prefix, "_group_175.csv")
label_fp_175 <- paste0(output_matrix_prefix, "_label_175.csv")
write.matrix(as.matrix(mcl_e2), file = group_fp_175, sep = ',')
write.matrix(as.matrix(hc_e_mash$labels), file = label_fp_175, sep = ',')

# 生成分组的树状图文件（1.5E-02阈值）
dendro_fp_15 <- paste0(output_image_prefix, "_dendrogram_15.png")
mcl_e2 <- cutree(hc_e_mash, h = max(hc_e_mash$height * 1.5E-02))
png(dendro_fp_15, units = "in", width = 30, height = 15, res = 360)
ColorDendrogram(hc_e_mash, y = mcl_e2, branchlength = 20)
dev.off()
# ====================================================

# ====================================================
# 保存分组和标签矩阵（150）
group_fp_150 <- paste0(output_matrix_prefix, "_group_150.csv")
label_fp_150 <- paste0(output_matrix_prefix, "_label_150.csv")
write.matrix(as.matrix(mcl_e2), file = group_fp_150, sep = ',')
write.matrix(as.matrix(hc_e_mash$labels), file = label_fp_150, sep = ',')

# 生成分组的树状图文件（1.25E-02阈值）
dendro_fp_125 <- paste0(output_image_prefix, "_dendrogram_125.png")
mcl_e2 <- cutree(hc_e_mash, h = max(hc_e_mash$height * 1.25E-02))
png(dendro_fp_125, units = "in", width = 30, height = 15, res = 360)
ColorDendrogram(hc_e_mash, y = mcl_e2, branchlength = 20)
dev.off()
# ====================================================

# ====================================================
# 保存分组和标签矩阵（125）
group_fp_125 <- paste0(output_matrix_prefix, "_group_125.csv")
label_fp_125 <- paste0(output_matrix_prefix, "_label_125.csv")
write.matrix(as.matrix(mcl_e2), file = group_fp_125, sep = ',')
write.matrix(as.matrix(hc_e_mash$labels), file = label_fp_125, sep = ',')


# 生成分组的树状图文件（1.25E-02阈值）
dendro_fp_125 <- paste0(output_image_prefix, "_dendrogram_125.png")
mcl_e2 <- cutree(hc_e_mash, h = max(hc_e_mash$height * 1.25E-02))
png(dendro_fp_125, units = "in", width = 30, height = 15, res = 360)
ColorDendrogram(hc_e_mash, y = mcl_e2, branchlength = 20)
dev.off()
# ====================================================


# ====================================================
# 保存分组和标签矩阵（300）
group_fp_300 <- paste0(output_matrix_prefix, "_group_300.csv")
label_fp_300 <- paste0(output_matrix_prefix, "_label_300.csv")
write.matrix(as.matrix(mcl_e2), file = group_fp_300, sep = ',')
write.matrix(as.matrix(hc_e_mash$labels), file = label_fp_300, sep = ',')


# 生成分组的树状图文件（3E-02阈值）
dendro_fp_300 <- paste0(output_image_prefix, "_dendrogram_300.png")
mcl_e2 <- cutree(hc_e_mash, h = max(hc_e_mash$height * 1.25E-02))
png(dendro_fp_300, units = "in", width = 30, height = 15, res = 360)
ColorDendrogram(hc_e_mash, y = mcl_e2, branchlength = 20)
dev.off()
# ====================================================


# ====================================================
# 保存分组和标签矩阵（500）
group_fp_500 <- paste0(output_matrix_prefix, "_group_500.csv")
label_fp_500 <- paste0(output_matrix_prefix, "_label_500.csv")
write.matrix(as.matrix(mcl_e2), file = group_fp_500, sep = ',')
write.matrix(as.matrix(hc_e_mash$labels), file = label_fp_500, sep = ',')


# 生成分组的树状图文件（5E-02阈值）
dendro_fp_500 <- paste0(output_image_prefix, "_dendrogram_500.png")
mcl_e2 <- cutree(hc_e_mash, h = max(hc_e_mash$height * 1.25E-02))
png(dendro_fp_500, units = "in", width = 30, height = 15, res = 360)
ColorDendrogram(hc_e_mash, y = mcl_e2, branchlength = 20)
dev.off()
# ====================================================


# ====================================================
# 保存分组和标签矩阵（700）
group_fp_700 <- paste0(output_matrix_prefix, "_group_700.csv")
label_fp_700 <- paste0(output_matrix_prefix, "_label_700.csv")
write.matrix(as.matrix(mcl_e2), file = group_fp_700, sep = ',')
write.matrix(as.matrix(hc_e_mash$labels), file = label_fp_700, sep = ',')


# 生成分组的树状图文件（7E-02阈值）
dendro_fp_700 <- paste0(output_image_prefix, "_dendrogram_700.png")
mcl_e2 <- cutree(hc_e_mash, h = max(hc_e_mash$height * 1.25E-02))
png(dendro_fp_700, units = "in", width = 30, height = 15, res = 360)
ColorDendrogram(hc_e_mash, y = mcl_e2, branchlength = 20)
dev.off()
# ====================================================