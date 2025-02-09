import sys
import argparse

def read_special_list(input_file):
    """
    读取列表文件，将结果存储在 special_list 数组中。
    """
    special_list = []
    with open(input_file, 'r') as file:
        for line in file:
            # 去除换行符并添加到 special_list
            special_list.append(line.strip())
    return special_list

def read_tsv_file(input_file):
    """
    读取 TSV 文件，将结果存储为一个二维字典。
    格式：{物种1: {物种2: 相似性, ...}, ...}
    """
    similarity_dict = {}
    with open(input_file, 'r') as file:
        for line in file:
            # 按制表符分割行
            parts = line.strip().split('\t')
            if len(parts) == 3:  # 确保每行有三列
                species1, species2, similarity = parts
                similarity = float(similarity)  # 将相似性转换为浮点数
                # 添加到二维字典
                if species1 not in similarity_dict:
                    similarity_dict[species1] = {}
                if species2 not in similarity_dict:
                    similarity_dict[species2] = {}
                similarity_dict[species1][species2] = similarity
                similarity_dict[species2][species1] = similarity  # 对称性
    return similarity_dict

def read_cluster_file(input_file):
    """
    读取簇文件，将每个簇存储为一个列表。
    """
    clusters = []
    with open(input_file, 'r') as file:
        for line in file:
            # 按制表符分割行，去除换行符并添加到 clusters
            species = line.strip().split('\t')
            clusters.append(species)
    return clusters

def select_representative(cluster, special_list, similarity_dict):
    """
    为每个簇选择一个代表性物种。
    逻辑：
    1. 如果簇内有 special_list 中的物种，则选择第一个在 special_list 中的物种。
    2. 如果没有，则选择簇内与其他物种相似性之和最小的物种。
    """
    # 检查是否有 special_list 中的物种
    for species in cluster:
        if species in special_list:
            return species  # 返回第一个在 special_list 中的物种

    # 如果没有，计算每个物种的相似性之和
    min_sum = float('inf')
    representative = None
    for species in cluster:
        similarity_sum = 0
        for other_species in cluster:
            if species != other_species:
                # 获取相似性（如果不存在则默认为 0）
                similarity_sum += similarity_dict.get(species, {}).get(other_species, 0)
        # 更新最小和及代表性物种
        if similarity_sum < min_sum:
            min_sum = similarity_sum
            representative = species
    return representative

def main():
    # 使用 argparse 解析命令行参数
    parser = argparse.ArgumentParser(description="Select representatives from clusters based on a special list and similarity scores.")
    parser.add_argument("-i", "--input", required=True, help="Input TSV file containing similarity scores.")
    parser.add_argument("-l", "--list", help="Optional list file. If provided, species in this list will be prioritized.")
    parser.add_argument("-c", "--cluster", required=True, help="Cluster file in TSV format.")
    parser.add_argument("-o", "--output", required=True, help="Output file to write the representatives.")
    args = parser.parse_args()

    # 读取相似性 TSV 文件
    similarity_dict = read_tsv_file(args.input)
    print(f"Similarity dictionary loaded.")

    # 读取簇 TSV 文件
    clusters = read_cluster_file(args.cluster)
    print(f"Clusters: {clusters}")

    # 如果提供了列表文件，则读取
    if args.list:
        special_list = read_special_list(args.list)
        print(f"Special list: {special_list}")
    else:
        special_list = []  # 如果没有提供列表文件，则使用空列表

    # 为每个簇选择代表性物种
    representatives = []
    for cluster in clusters:
        representative = select_representative(cluster, special_list, similarity_dict)
        representatives.append(representative)
    print(f"Representatives: {representatives}")

    # 将代表性物种列表写入输出文件
    with open(args.output, 'w') as file:
        for representative in representatives:
            file.write(f"{representative}\n")

    print(f"Output written to {args.output}")

if __name__ == "__main__":
    main()