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


###