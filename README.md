# Phylogeny-of-E.-coli

### 基因组下载

基因组下载过程：......

基因组数量：40472 （基因组GCF编号见[GCF_id.zip](data/GCF_id.zip)）

### 基因组去重

removed redundancy (all pairs of genomes are divergent >0.01%)

使用FastGA、pgr、wgatools等工具快速得到基因组间divergent；
使用hnsm等工具快速进行基因组去重

最终去重后的基因组数量：27377 （（基因组GCF编号见[rep_GCF_id.zip](data/rep_GCF_id.zip)））  过程如下：



```shell

bash script/1.sh -i test/pairs_genome.txt  -o output/result.tsv  # 脚本中内置基因组genome.fa目录和python脚本目录，后续使用需更改

## 输入文件为pairs of genomes列表文件
# Esc_coli_08_A138_A_GCF_005399065_1      Esc_coli_DOHRS2_GCF_022550995_1
# Esc_coli_102536_GCF_001265655_1 Esc_coli_TA2019180_GCF_024354945_1

## 输出文件为基因组染色体divergent和coverage
# Esc_coli_08_A138_A_GCF_005399065_1      Esc_coli_DOHRS2_GCF_022550995_1 0.004068        0.94276 0.944487
# Esc_coli_102536_GCF_001265655_1 Esc_coli_TA2019180_GCF_024354945_1      0.001726        0.914553        0.931488


hnsm cluster --mode dbscan --eps 0.0001 -i test/divergent.tsv -o output/cluster.tsv

## 输出文件为聚类文件，后续从每一个cluster中选出一个代表性菌株

# Esc_coli_B42_3_GCF_026420765_1
# Esc_coli_49_J25_A_GCF_005399965_1
# Esc_coli_ZJ_88_GCF_034718995_1  Esc_coli_ZJ_88_GCF_034365505_1
# Esc_coli_MOD1_EC5539_GCF_002228755_1    Esc_coli_MOD1_EC5540_GCF_002228625_1
# Esc_coli_LEH_24_GCF_029167305_1
# Esc_coli_UMEA_3703_1_GCF_000461615_1
# Esc_coli_KS_P067_GCF_005392785_1
# Esc_coli_550_CL100127346_L02_GCF_021648955_1    Esc_coli_GX330_GCF_032291165_1  Esc_coli_GX321_1_GCF_032291185_1        Esc_coli_GX540_GCF_032290685_1  Esc_coli_542_CL100127346_L02_GCF_021648995_1

python script/rep_strains.py -i test/cluster.tsv -l rep.list -c test/divergent.tsv  -o output/rep_strains.txt

## 使用cluser内的中心点作为代表性菌株,可在rep.list认为选择代表性菌株

```

### ClermonTyping 鉴定大肠杆菌类群

参考[Olivier Clermont方法](https://www.microbiologyresearch.org/content/journal/mgen/10.1099/mgen.0.000192)定义大肠杆菌系统发育类群

```shell
bash clermonTyping.sh --fasta /mnt/d/2024-1-evolution/Es_coli_Shig_40472/epcr/data_db/Esc_coli_00_12_GCF_022131205_1/genome.fna
# Esc_coli_00_12_GCF_022131205_1  ['trpBA', 'chuA', 'yjaA', 'trpAgpC']    ['-', '+', '+', '-']    ['trpAgpC']     B2      Esc_coli_00_12_GCF_022131205_1_mash_screen.tab
```



### mash、bac120、f88 分析与逻辑斯蒂回归

得到三种基因组分析方法成对基因组间的遗传距离如下：


bac120

```shell
# 输入文件 pro.fa.gz  strains.tsv
cd /scratch/wangq/llj/Es_coli_Shig_40472

cat tmp_strains.tsv |
        parallel --colsep '\t' --no-run-if-empty --linebuffer -k -j 1 '
            gzip -dcf /mnt/d/wangq-date/Bacteria/ASSEMBLY/{2}/{1}/*_protein.faa.gz |
                grep "^>" |
                sed "s/^>//" |
                sed "s/'\''//g" |
                sed "s/\-\-//g" |
                perl -nl -e '\'' s/\s+\[.+?\]$//g; print; '\'' |
                sed "s/MULTISPECIES: //g" |
                perl -nl -e '\''
                    /^(\w+)\.(\d+)\s+(.+)$/ or next;
                    printf qq(%s.%s\t%s\t%s\n), $1, $2, qq({1}), $3;
                '\'' \
                >> tmp_detail.tsv

            gzip -dcf /mnt/d/wangq-date/Bacteria/ASSEMBLY/{2}/{1}/*_protein.faa.gz
        ' |
        hnsm filter stdin -u |
        hnsm gz stdin -p 4 -o protein/pro.fa


tsv-select -f 1,3 protein/detail.tsv | tsv-uniq | gzip > protein/anno.tsv.gz
tsv-select -f 1,2 protein/detail.tsv | tsv-uniq | gzip > protein/asmseq.tsv.gz
rm -f protein/detail.tsv

cd protein


mmseqs easy-cluster pro.fa.gz rep tmp --threads 4 --remove-tmp-files -v 0 --min-seq-id 0.95 -c 0.95

hnsm gz rep_rep_seq.fasta -o rep_seq.fa

rm rep_all_seqs.fasta
rm rep_rep_seq.fasta



mmseqs easy-cluster rep_seq.fa.gz fam88 tmp --threads 8 --remove-tmp-files -v 0 --min-seq-id 0.8 -c 0.8

rm fam88_all_seqs.fasta
rm fam88_rep_seq.fasta

mmseqs easy-cluster rep_seq.fa.gz fam38 tmp --threads 8 --remove-tmp-files -v 0 --min-seq-id 0.3 -c 0.8

rm fam38_all_seqs.fasta
rm fam38_rep_seq.fasta


nwr seqdb -d protein/ --init --strain

nwr seqdb -d protein --size <(hnsm size protein/pro.fa.gz) --clust

nwr seqdb -d protein --anno <(gzip -dcf protein/anno.tsv.gz) --asmseq <(gzip -dcf protein/asmseq.tsv.gz)
nwr seqdb -d protein --rep f1=protein/fam88_cluster.tsv
nwr seqdb -d protein --rep f2=protein/fam38_cluster.tsv




nwr kb bac120 -o HMM

cp HMM/bac120.lst HMM/marker.lst

mkdir -p Domain


cat HMM/marker.lst |
    parallel --colsep '\t' --no-run-if-empty --linebuffer -k -j 8 "
        gzip -dcf protein/rep_seq.fa.gz |
            hmmsearch --cut_nc --noali --notextw HMM/hmm/{}.HMM - |
            grep '>>' |
            perl -nl -e ' m(>>\s+(\S+)) and printf qq(%s\t%s\t%s\n), q({}), \$1; '
    " > protein/bac120.tsv



nwr seqdb -d protein/ --rep f3=protein/bac120.tsv





echo "
    SELECT
        seq.name,
        asm.name,
        rep.f3
    FROM asm_seq
    JOIN rep_seq ON asm_seq.seq_id = rep_seq.seq_id
    JOIN seq ON asm_seq.seq_id = seq.id
    JOIN rep ON rep_seq.rep_id = rep.id
    JOIN asm ON asm_seq.asm_id = asm.id
    WHERE 1=1
        AND rep.f3 IS NOT NULL
    ORDER BY
        asm.name,
        rep.f3
    " |
    sqlite3 -tabs protein/seq.sqlite \
    > protein/seq_asm_f3.tsv


hnsm some protein/pro.fa.gz <(tsv-select -f 1 protein/seq_asm_f3.tsv | tsv-uniq) | hnsm dedup stdin | hnsm gz stdin -o Domain/bac120.fa

cp protein/seq_asm_f3.tsv Domain/seq_asm_f3.tsv


cat HMM/marker.lst |
    parallel --no-run-if-empty --linebuffer -k -j 4 '
        echo >&2 "==> marker [{}]"

        mkdir -p Domain/{}

        hnsm some Domain/bac120.fa.gz <(
            cat Domain/seq_asm_f3.tsv |
                tsv-filter --str-eq "3:{}" |
                tsv-select -f 1 |
                tsv-uniq
            ) \
            > Domain/{}/{}.pro.fa
    '

cat HMM/marker.lst |
    parallel --no-run-if-empty --linebuffer -k -j 8 '
        echo >&2 "==> marker [{}]"
        if [ ! -s Domain/{}/{}.pro.fa ]; then
            exit
        fi
        if [ -s Domain/{}/{}.aln.fa ]; then
            exit
        fi

        mafft --auto Domain/{}/{}.pro.fa > Domain/{}/{}.aln.fa
    '


cat HMM/marker.lst |
while read marker; do
    echo >&2 "==> marker [${marker}]"
    if [ ! -s Domain/${marker}/${marker}.pro.fa ]; then
        continue
    fi

    # sometimes `muscle` can not produce alignments
    if [ ! -s Domain/${marker}/${marker}.aln.fa ]; then
        continue
    fi

    # Only NR strains
    # 1 name to many names
    cat Domain/seq_asm_f3.tsv |
        tsv-filter --str-eq "3:${marker}" |
        tsv-select -f 1-2 |
        hnsm replace -s Domain/${marker}/${marker}.aln.fa stdin \
        > Domain/${marker}/${marker}.replace.fa
done

cat HMM/marker.lst |
while read marker; do
    if [ ! -s Domain/${marker}/${marker}.pro.fa ]; then
        continue
    fi
    if [ ! -s Domain/${marker}/${marker}.aln.fa ]; then
        continue
    fi

    cat Domain/${marker}/${marker}.replace.fa

    # empty line for .fas
    echo
done \
    > Domain/bac120.aln.fas


cat Domain/seq_asm_f3.tsv |
    cut -f 2 |
    tsv-uniq |
    sort |
    fasops concat Domain/bac120.aln.fas stdin -o Domain/bac120.aln.fa




trimal -in Domain/bac120.aln.fa -out Domain/bac120.trim.fa -automated1

FastTree -fastest -noml Domain/bac120.trim.fa > Domain/bac120.trim.newick

```

mash

```shell

mash dist -p 23 all_genome.msh all_genome.msh >> result/mash_distance.tsv

```

f88

```shell
# fam88

echo "
    SELECT
        seq.name,
        asm.name,
        rep.f1
    FROM asm_seq
    JOIN rep_seq ON asm_seq.seq_id = rep_seq.seq_id
    JOIN seq ON asm_seq.seq_id = seq.id
    JOIN rep ON rep_seq.rep_id = rep.id
    JOIN asm ON asm_seq.asm_id = asm.id
    WHERE 1=1
        AND rep.f1 IS NOT NULL
    ORDER BY
        asm.name,
        rep.f1
    " |
    sqlite3 -tabs protein/seq.sqlite \
    > protein/seq_asm_f88.tsv


python3 script/famN_value.py -i protein/seq_asm_f88.tsv -o result/value/f88_value.tsv -r protein/f88.list


hnsm similarity --mode jaccard --bin --dis result/value/f88_value.tsv -o result/f88_distance.tsv


```


三种方法进行层次聚类分析：

```shell
# 以mash_distacne.tsv为例
# 将mash_distacne.tsv转化为n维的矩阵作为输出文件 mash_distance.csv
# group文件为菌株Clermont分类文件 如下：
# Esc_coli_00_12_GCF_022131205_1  B2
# Esc_coli_00_3279_GCF_002741155_1        B1

Rscript 1.R test/mash_distance.csv test/group.tsv output/mash.png  # 层次聚类热图

Rscript 2.R test/mash_distance.csv mash mash  # mash为输出文件前缀


```

对得到的类群进行进行比较得到共有类群和分歧类群

```shell

python scrppt/combine.py mash_cluster bac120_cluster f88_cluster  mash_bac120_f88_cluster.tsv

```

使用分类明确的类群进行逻辑斯蒂回归

```shell

# 以志贺氏属为例

Rscript script/logistic_regression.R combine_phy.tsv test/mash_distance.csv test/bac120_distance.csv test/f88_distance.csv

# combine_phy.tsv 为成对基因组分类关系，0为相同phylogroup，1为不同phylogroup
# Shig_boy_59_2708_GCF_002949495_1        Shig_boy_600690_GCF_001906135_1 0
# Shig_boy_59_2708_GCF_002949495_1        Shig_boy_CIP_56_18_GCF_032362635_1      0
# Shig_boy_59_2708_GCF_002949495_1        Shig_boy_600690_GCF_013394515_1 0
# Shig_boy_06_3595_GCF_031665755_1        Shig_boy_59_2708_GCF_002949495_1        0
# Shig_boy_600690_GCF_001906135_1 Shig_boy_CIP_56_18_GCF_032362635_1      0
# Shig_boy_09_0344_GCF_000815785_1        Shig_flexn_4028STDY6275096_GCF_900486095_1      1
# Shig_boy_BCW_4868_GCF_001933075_2       Shig_flexn_4028STDY6275096_GCF_900486095_1      1
# Shig_boy_600690_GCF_013394515_1 Shig_flexn_4028STDY6275096_GCF_900486095_1      1
# Shig_boy_59_248_GCF_002949475_1 Shig_flexn_4028STDY6275096_GCF_900486095_1      1
# Shig_boy_NCTC_9850_GCF_002949175_1      Shig_flexn_4028STDY6275096_GCF_900486095_1      1
# Shig_boy_08_2671_GCF_000815725_1        Shig_flexn_4028STDY6275096_GCF_900486095_1      1

```