#!/bin/bash

# ====================================================================
# Script 3: Phylogenetic Tree Building and Core Diversity Analysis
#
# Objective: 1. Build phylogenetic tree (for Unifrac distance)
#          2. Run core diversity metrics (Alpha & Beta)
# ====================================================================


# --- Phylogenetic Tree Building ---
echo "--- Step1:Phylogenetic Tree Building (MAFFT + FastTree) ---"
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seq.qza \
  --o-alignment aligned-rep-seq.qza \
  --o-masked-alignment masked-aligned-rep-seq.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza


# --- Core Diversity Analysis ---
# !! WARNING: --p-sampling-depth is  critical parameter.
# This must be determined based on the table.qzv report produced by 2_dada2_denoise.sh.
# The goal is to select a depth that is as high as possible, but still retains all (or the vast majority of) samples.
SAMPLING_DEPTH=10000

echo "--- Step2: Computing core diversity metrics ---"
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth $SAMPLING_DEPTH \
  --m-metadata-file sample-metadata.tsv \
  --output-dir core-metrics-results

# In core-metrics-results: PCoA plots, Alpha/Beta diversity matrix, rarefied_table.qza (after sampling)

echo "--- Step 3: Generate Alpha Rarefaction Curves ---"
# This step is used to validate if your $SAMPLING_DEPTH is reasonable
# --p-max-depth should be set to the maximum sequence count observed in table.qzv

# curve turns to flat before reads reach sample length is the expected results, if not, adjust the $SAMPLING_DEPTH 
qiime diversity alpha-rarefaction \
  --i-table table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 30000 \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization alpha-rarefaction.qzv



echo "---  Script 3: Phylogenetic Tree Building and Core Diversity Analysis is completed ---"
echo "Outputs:"
echo "1. rooted-tree.qza (Phylogenetic Trss)"
echo "2. core-metrics-results/ (contain all .qza file related to Alpha and Beta diversity)"
echo "Visualizaiton:"
echo "1. alpha-rarefaction.qzv (check whether samping_depth is enough to catch the diversity)"
echo "2. core-metrics-results/*.qzv (PCoA plots etc.)"