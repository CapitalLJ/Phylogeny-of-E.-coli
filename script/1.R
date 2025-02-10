library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(gplots)
library(pheatmap)

# 解析命令行参数
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 3) {
  stop("Usage: Rscript generate_heatmap.R <distance_matrix.csv> <group.tsv> <output_image.png>")
}

# 从命令行读取输入文件和输出图片路径
distance_matrix_file <- args[1]
group_file <- args[2]
output_image <- args[3]

# 读取距离矩阵数据
distance_matrix <- as.matrix(read.csv(distance_matrix_file, sep = ',', header = TRUE, row.names = 1))

# 创建距离矩阵和层次聚类
dis_e_mash <- as.dist(distance_matrix)
hc_e_mash <- hclust(dis_e_mash, method = 'ward.D2')

# 读取分组数据
group_data <- read.table(group_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
strains <- group_data$V1
groups <- group_data$V2

# 定义每个分组的颜色
group_colors <- c("A" = "pink", "B1" = "red", "B2" = "blue", "C" = "green", "D" = "yellow",
                  "E" = "purple", "F" = "orange", "G" = "cyan", "others" = "gray", "shig" = "brown")

# 创建一个因子变量，表示每个物种的分组
group_factor <- factor(groups, levels = names(group_colors))

# 映射分组颜色
col_side_colors <- group_colors[group_factor]

# 保存热图为 PNG 文件
png(output_image, units = 'in', width = 30, height = 15, res = 360)

# 绘制热图
heatmap(distance_matrix,
        Rowv = as.dendrogram(hc_e_mash),
        Colv = 'Rowv',  # 只显示行的树状图
        col = colorRampPalette(rev(brewer.pal(n = 11, name = "BrBG")))(200),
        scale = 'none',
        labRow = FALSE,
        labCol = TRUE,
        ColSideColors = col_side_colors,
        main = "Clustered Heatmap with Legend"
)

# 手动添加图例
legend("topright",  # 图例的位置
       legend = names(group_colors),  # 图例标签（分组名称）
       fill = group_colors,  # 图例颜色
       title = "Group",  # 图例标题
       cex = 2.4,  # 字体大小
       bty = "n")  # 去掉图例边框

# 关闭图形设备
dev.off()