#!/bin/bash

# ====================================================================
# Script 2: DADA2 denoising

# Target: run DADA2, do quality control , denoising, merge and remove chimeric
#         generate Feature table and representative sequences
# ====================================================================

# --- DADA2 parameters setting ---
# The parameters should be adjusted by the demux.qzv from 1_import_and_qc.sh output
TRIM_LEFT_F=20
TRIM_LEFT_R=20
TRUNC_LEN_F=250
TRUNC_LEN_R=250
N_THREADS=16 

echo "--- Run DADA2 (denoise-paired) ---"

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux.qza \
  --p-trim-left-f $TRIM_LEFT_F \
  --p-trim-left-r $TRIM_LEFT_R \
  --p-trunc-len-f $TRUNC_LEN_F \
  --p-trunc-len-r $TRUNC_LEN_R \
  --o-table table.qza \
  --o-representative-sequences rep-seq.qza \
  --o-denoising-stats denoising-stats.qza \
  --p-n-threads $N_THREADS

# table.qza: feature table. Each column: sSampleA, num of ASV_1, num of ASV_2
# rep-seq.qza representative-sequences.qza
# denoising-stats.qza

echo "--- Generate quality control report after DADA2 ---"
# 1. summery of feature table, check the reads of each sample to determine sampling depth
qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file sample-metadata.tsv

# 2. Summary of representative sequences
qiime feature-table tabulate-seqs \
  --i-data rep-seq.qza \
  --o-visualization rep-seq.qzv

# 3. DADA2 denoising statistics (Check how many reads are filtered at this step)
# input filtered denoised merged non-chimeric            chimeric: bateriaA + bateriaB
qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv

echo "--- Script2:DADA2 denoising is completed---"
echo "Outputs:"
echo "1. table.qza (feature table)"
echo "2. rep-seq.qza (representative sequences)"
echo "Visualizaiton:"
echo "1. table.qzv (check the reads of each sample to determine sampling depth)"
echo "2. denoising-stats.qzv (Check how many reads are filtered at this step)"


