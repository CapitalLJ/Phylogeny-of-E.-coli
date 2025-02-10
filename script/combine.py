import sys

def process_file(input_file):
    cluster = {}
    uniq_id = []
    with open(input_file, 'r') as file:
        for line in file:
            fields = line.strip().split('\t')
            if len(fields) > 1:
                cluster[fields[0]] = fields
            else:
                uniq_id.append(fields[0])
    return cluster, uniq_id


def combine_clusters(cluster1, uniq1, cluster2, uniq2):
    """合并两个聚类结果（原逻辑保留用于第四个文件）"""
    combined = {}
    common_uniq = list(set(uniq1) & set(uniq2))
    
    for cid1 in cluster1:
        for cid2 in cluster2:
            common = list(set(cluster1[cid1]) & set(cluster2[cid2]))
            if len(common) > 1:
                combined[common[0]] = common
    return combined, common_uniq

def write_output(cluster, uniq, filename):
    """写入聚类结果（用于第四个文件）"""
    with open(filename, 'w') as f:
        for cid in cluster:
            f.write('\t'.join(cluster[cid]) + '\n')
        for strain in uniq:
            f.write(strain + '\n')

def write_strain_list(strains, filename):
    """写入菌株列表（用于前三个文件）"""
    with open(filename, 'w') as f:
        for strain in strains:
            f.write(strain + '\n')

if __name__ == "__main__":
    # 输入参数
    file1 = sys.argv[1]
    file2 = sys.argv[2]
    file3 = sys.argv[3]
    out_common = sys.argv[3]  # 三个共有的
    
    # 处理文件
    c1, u1 = process_file(file1)
    c2, u2 = process_file(file2)
    c3, u3 = process_file(file3)
    
    
    # 生成三个文件共同聚类（原逻辑）
    # 先合并1和2
    comb12, u_comb12 = combine_clusters(c1, u1, c2, u2)
    # 再与3合并
    comb123, u_comb123 = combine_clusters(comb12, u_comb12, c3, u3)
    # 写入第四个文件
    write_output(comb123, u_comb123, out_common)
    
    # 输出统计信息
    print(f"[共同聚类] 簇数量: {len(comb123)}, 包含菌株: {sum(len(v) for v in comb123.values())}")
