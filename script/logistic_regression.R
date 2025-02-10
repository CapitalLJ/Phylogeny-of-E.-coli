#!/usr/bin/env Rscript

# 加载必要的库
library(car)  # 用于计算VIF（方差膨胀因子）
library(stats)  # 用于逻辑回归
library(dplyr)

# 从命令行获取参数
args <- commandArgs(trailingOnly = TRUE)

# 检查参数数量是否正确
if (length(args) < 4) {
  stop("Usage: Rscript logistic_regression.R <classification_file> <distance_file1> <distance_file2> <distance_file3>", call. = FALSE)
}

# 解析参数
classification_file <- args[1]  # 分类文件路径
distance_files <- args[2:4]     # 距离文件路径
distance_names <- c("bac120", "mash", "f88")  # 距离变量名称

# 读取分类文件
classification_data <- read.table(classification_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
colnames(classification_data) <- c("species1", "species2", "classification")

# 合并距离数据
merged_data <- classification_data
for (i in seq_along(distance_files)) {
  distance_data <- read.table(distance_files[i], header = FALSE, sep = "\t", stringsAsFactors = FALSE)
  colnames(distance_data) <- c("species1", "species2", distance_names[i])
  
  # 将距离数据合并到分类数据中
  merged_data <- merged_data %>%
    left_join(distance_data, by = c("species1", "species2"))
}

# 检查是否有缺失值
if (any(is.na(merged_data))) {
  print("Warning: Missing values detected in the merged data. Rows with missing values will be removed.")
  merged_data <- na.omit(merged_data)
}

# 逻辑斯蒂回归
logistic_model <- glm(classification ~  bac120 + f88 + mash, data = merged_data, family = binomial(link = "logit"))

# 输出回归结果
summary(logistic_model)

# 提取回归系数和 p 值
coefficients <- coef(summary(logistic_model))
p_values <- coefficients[, "Pr(>|z|)"]
odds_ratios <- exp(coef(logistic_model))

# 打印结果
cat("Logistic Regression Results:\n")
cat("---------------------------\n")
cat("Coefficients:\n")
print(coefficients)
cat("\nOdds Ratios:\n")
print(odds_ratios)
cat("\nP-values:\n")
print(p_values)

cat("\nChecking Independence Between Variables:\n")
cat("--------------------------------------\n")

# 1. 计算皮尔逊相关系数
correlation_matrix <- cor(merged_data[, c("bac120", "mash", "f88")], method = "pearson")
cat("Pearson Correlation Matrix:\n")
print(correlation_matrix)

# 2. 计算方差膨胀因子 (VIF)
vif_values <- vif(logistic_model)
cat("\nVariance Inflation Factor (VIF):\n")
print(vif_values)

# 3. 绘制散点图矩阵
png("scatterplot_matrix.png")  # 将散点图保存为文件
pairs(merged_data[, c("bac120", "mash", "f88")], main = "Scatterplot Matrix of bac120, mash, and f88")
dev.off()
cat("\nScatterplot matrix saved as 'scatterplot_matrix.png'.\n")