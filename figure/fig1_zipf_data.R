


# Rscript fig1_zipf_data.R

# setwd("e:/backupdata/coli/data")

library(readr)
library(tidyverse)

# data
data <- read_tsv("genome_count.tsv")
fit_data <- data %>%
    slice(1:5) %>%
    select(Number, Count)

# Zipf's Law function
zipf_law <- function(r, C, s) {
    return(C / r^s)
}

# Fit the model using nls
fit <- nls(Count ~ zipf_law(Number, C, s), data = fit_data, start = list(C = 10000, s = 1), control = nls.control(maxiter = 100))
C <- coef(fit)["C"]
s <- coef(fit)["s"]

# Initialize the results data frame
results <- tibble(
    rows = integer(),
    p_value = numeric(),
    significance = character()
)

# Kolmogorov-Smirnov test for increasing rows
for (i in 5:nrow(data)) {
    test_data <- data %>%
        slice(1:i) %>%
        select(Number, Count)
    
    fitted_values <- zipf_law(test_data$Number, C, s)
    
    ks_result <- ks.test(test_data$Count, fitted_values)
    p_value <- ks_result$p.value
    significance <- case_when(
        p_value < 0.001 ~ "***",
        p_value < 0.01  ~ "**",
        p_value < 0.05  ~ "*",
        TRUE ~ "ns"
    )
    results <- bind_rows(results, tibble(rows = i, p_value = p_value, significance = significance))
}

write_tsv(results, "zipf_result.tsv")

