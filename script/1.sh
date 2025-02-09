#!/usr/bin/env bash

while getopts "i:o:" opt; do
  case $opt in
    i)
      input_file=$OPTARG
      ;;
    o)
      output_dir=$OPTARG
      ;;
    *)
      echo "Usage: $0 -i <input_file> -o <output_dir>"
      exit 1
      ;;
  esac
done

export PATH=/share/home/wangq/llj/app/wgatools/target/x86_64-unknown-linux-gnu/release:$PATH
export PATH=/share/home/wangq/llj/app/hnsm/target/x86_64-unknown-linux-gnu/release:$PATH

mkdir -p "$output_dir"

process_strains() {
    local strain1=$1
    local strain2=$2
    local output_dir=$3

    local temp_dir=$(mktemp -d -p "$output_dir" tempdir_XXXXXX)
    cp "/scratch/wangq/llj/Es_coli_Shig_40472/epcr/data_db/$strain1/genome.fna" "$temp_dir/1.fa"
    cp "/scratch/wangq/llj/Es_coli_Shig_40472/epcr/data_db/$strain2/genome.fna" "$temp_dir/2.fa"

    # 第一步：FastGA，限制时间为 30 秒
    if timeout 30s FastGA -v -psl -T1 "$temp_dir/1.fa" "$temp_dir/2.fa" > "$temp_dir/${strain1}_${strain2}.psl" 2>/dev/null; then
        echo "FastGA completed for $strain1 and $strain2."
    else
        echo "FastGA timed out for $strain1 and $strain2. Skipping..."
        touch "$temp_dir/${strain1}_${strain2}.fastga_timeout"
        rm -rf "$temp_dir"  # 删除临时文件
        return  # 跳过后续步骤
    fi

    # 第二步：pgr chain，限制时间为 1 分钟
    if timeout 1m pgr chain --syn "$temp_dir/2.fa" "$temp_dir/1.fa" "$temp_dir/${strain1}_${strain2}.psl" > "$temp_dir/${strain1}_${strain2}.maf" 2>/dev/null ; then
        echo "pgr chain completed for $strain1 and $strain2."
    else
        echo "pgr chain timed out for $strain1 and $strain2. Skipping..."
        touch "$temp_dir/${strain1}_${strain2}.pgr_timeout"
        rm -rf "$temp_dir"  # 删除临时文件
        return  # 跳过后续步骤
    fi

    # 后续步骤  使用了wgatools python脚本
    wgatools maf2paf "$temp_dir/${strain1}_${strain2}.maf" > "$temp_dir/${strain1}_${strain2}.paf"
    python3 /scratch/wangq/llj/Es_coli_Shig_40472/FastGA/script/paf_intrac.py -i "$temp_dir/${strain1}_${strain2}.paf" -o "$output_dir/${strain1}_${strain2}.tsv" -q "$strain1" -t "$strain2"

    # 删除临时文件
    rm -rf "$temp_dir"
}

export -f process_strains

parallel -j 23 --colsep '\t' process_strains {1} {2} "$output_dir" :::: "$input_file"

> "$output_dir/result.list"
for i in "$output_dir"/*.tsv; do
    cat "$i" >> "$output_dir/result.list"
done

# 删除所有 .tsv 文件
rm -f "$output_dir"/*.tsv
