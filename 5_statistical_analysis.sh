#!/bin/bash

# ====================================================================
# Script 5: Statistical Analysis
#
# Objective: 1. Test for group differences in Alpha and Beta diversity
#          2. Run ANCOM to find differentially abundant taxa
# ====================================================================




# --- 1. Alpha Diversity Significance Test(Kruskal-Wallis) ---
echo "--- Running Alpharsity Statistics ---"
METRICS_DIR="core-metrics-results"
META_FILE="sample-metadata.tsv"
OUTPUT_DIR="stats_alpha"
mkdir -p $OUTPUT_DIR

# Loop through all alpha diversity metrics (e.g., shannon, faith_pd, ...)

for i in $(ls $METRICS_DIR/*_vector.qza); do
  # Extract filename
  metric_name=$(basename $i _vector.qza)
  
  echo "qiime diversity alpha-group-significance \
    --i-alpha-diversity $i \
    --m-metadata-file $META_FILE \
    --o-visualization $OUTPUT_DIR/${metric_name}-group-significance.qzv"

done > alpha_group_significance.sh

sh alpha_group_significance.sh

# --- 2. Beta Diversity Significance Test (PERMANOVA) ---
echo "--- Running Beta Diversity Statistics (PERMANOVA) ---"
OUTPUT_DIR="stats_beta"
mkdir -p $OUTPUT_DIR

# Loop through all beta diversity distance matrices (e.g., bray_curtis, unifrac, ...)
for i in $(ls $METRICS_DIR/*_distance_matrix.qza); do
  matrix_name=$(basename $i _distance_matrix.qza)

  # Compare 'disease_type'
  echo "qiime diversity beta-group-significance \
    --i-distance-matrix $i \
    --m-metadata-file $META_FILE \
    --m-metadata-column disease_type \
    --o-visualization $OUTPUT_DIR/${matrix_name}-disease.qzv \
    --p-pairwise"
    
  # Compare 'subgroup'
  echo "qiime diversity beta-group-significance \
    --i-distance-matrix $i \
    --m-metadata-file $META_FILE \
    --m-metadata-column subgroup \
    --o-visualization $OUTPUT_DIR/${matrix_name}-subgroup.qzv \
    --p-pairwise"

done > beta_group_significance.sh

sh beta_group_significance.sh


# --- 3. Differential Abundance Analysis (ANCOM) ---
# what bateria cause the difference between groups
echo "--- Running Differential Abundance Analysis (ANCOM) ---"
OUTPUT_DIR="stats_ancom"
mkdir -p $OUTPUT_DIR


# --- Use raw count table (table.qza)---
echo "--- ANCOM on ASV level ---"
# add tiny pseudocount to 0
qiime composition add-pseudocount \
  --i-table table.qza \
  --o-composition-table comp-table-raw.qza

# Difference in ASV level 
qiime composition ancom \
  --i-table comp-table-raw.qza \
  --m-metadata-file $META_FILE \
  --m-metadata-column disease_type \
  --o-visualization $OUTPUT_DIR/ancom-disease-raw-ASV.qzv

qiime composition ancom \
  --i-table comp-table-raw.qza \
  --m-metadata-file $META_FILE \
  --m-metadata-column subgroup \
  --o-visualization $OUTPUT_DIR/ancom-subgroup-raw-ASV.qzv

# Run at L6 (Genus) level
echo "--- ANCOM on Genus level (L6) ---"
# collapese table.qza from ASV level to Genus level
qiime taxa collapse \
  --i-table table.qza \
  --i-taxonomy taxonomy_customized.qza \
  --p-level 6 \
  --o-collapsed-table table-l6-raw.qza

qiime composition add-pseudocount \
  --i-table table-l6-raw.qza \
  --o-composition-table comp-table-l6-raw.qza

#Difference in geneus level
qiime composition ancom \
  --i-table comp-table-l6-raw.qza \
  --m-metadata-file $META_FILE \
  --m-metadata-column disease_type \
  --o-visualization $OUTPUT_DIR/ancom-disease-raw-L6.qzv

qiime composition ancom \
  --i-table comp-table-l6-raw.qza \
  --m-metadata-file $META_FILE \
  --m-metadata-column subgroup \
  --o-visualization $OUTPUT_DIR/ancom-subgroup-raw-L6.qzv

echo "--- Step 5: Statistical Analysis Complete ---"
echo "Outputs: stats_alpha/, stats_beta/, stats_ancom/ folders"
echo "Please check the .qzv files to see group differences."
"