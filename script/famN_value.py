import argparse


def parse_args():
    parser = argparse.ArgumentParser(description="Parse input and output file paths.")
    parser.add_argument('-i', '--input', required=True, help='Input file (info.tsv)')
    parser.add_argument('-o', '--output', required=True, help='Output directory for main output file')
    parser.add_argument('-r', '--rep_output', required=True, help='Output file for rep list')
    return parser.parse_args()


def read_info(input_file):
    strain_rep = {}
    rep_list = set()

    with open(input_file, 'r') as file:
        for line in file:
            data = line.strip().split('\t')
            strain_name, rep_name = data[1], data[2]

            rep_list.add(rep_name)
            strain_rep.setdefault(strain_name, {}).setdefault(rep_name, 0)
            strain_rep[strain_name][rep_name] += 1

    return strain_rep, sorted(rep_list)


def write_output(rep_list, strain_rep, output_file):
    with open(output_file, 'w') as f:
        for strain, rep_counts in strain_rep.items():
            line = f"{strain}\t" + ",".join(str(rep_counts.get(rep, 0)) for rep in rep_list)
            f.write(line + "\n")


def write_rep_list(rep_list, rep_output_file):
    with open(rep_output_file, 'w') as f:
        for rep in rep_list:
            f.write(rep + "\n")


if __name__ == '__main__':
    args = parse_args()
    strain_rep, rep_list = read_info(args.input)
    write_output(rep_list, strain_rep, args.output)
    write_rep_list(rep_list, args.rep_output)
    print("Output completed.")