import argparse

# 输入文件夹为epcr结果，列表文件为菌株名称
def normol_get():
    parser = argparse.ArgumentParser(description="python cluster_count.py -i input_file -m multi_file -o output_file")
    parser.add_argument('-i', '--input', help='输入文件夹')
    parser.add_argument('-q', '--query', help='查询菌株名称')
    parser.add_argument('-t', '--target', help='目标菌株名称')
    parser.add_argument('-o', '--output', help='输出文件')
    args = parser.parse_args()

    return args


def read_input(input_file):
    pre_length = 0
    pre2_length = 0
    align_length = 0
    chr_list = []
    chr_sun_length = 0
    chr2_list = []
    chr2_sun_length = 0

    with open(input_file, "r") as file:
        for line in file:
            data = line.strip().split('\t')
            yuanchang = int(data[3]) - int(data[2])
            yuanchang2 = int(data[8]) - int(data[7])
            pre_length += yuanchang
            pre2_length += yuanchang2
            align_length += int(data[9])
            chr_name = data[0]
            chr2_name = data[5]
            if chr_name not in chr_list:
                chr_sun_length += int(data[1])
                chr_list.append(chr_name)
            if chr2_name not in chr2_list:
                chr2_sun_length += int(data[6])
                chr2_list.append(chr2_name)

    # 处理 pre_length 为零的情况
    if pre_length > 0:
        similarity = round(align_length / pre_length, 6)  # 四舍五入到万分位
        identy = round(pre_length / chr_sun_length, 6)
        identy2 = round(pre2_length / chr2_sun_length, 6)
    else:
        similarity = 0
        identy = 0  # 设置默认值
        identy2 = 0  # 设置默认值

    divergent = round(1 - similarity, 6)
    return divergent, identy, identy2


def process(input_file, output_file, query, target):
    with open(output_file, "w") as file:
        divergent, identy, identy2 = read_input(input_file)
        file.write(f"{query}\t{target}\t{divergent}\t{identy}\t{identy2}\n")


if __name__ == '__main__':
    args = normol_get()
    input_file = args.input
    output_file = args.output
    query = args.query
    target = args.target

    process(input_file, output_file, query, target)