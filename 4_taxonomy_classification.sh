#!/bin/bash

# ====================================================================
# Script 4: Taxonomic Classification
#
# Objective: Assign taxonomic information to ASVs.
# Strategy: Method B (custom classifier) is the more rigorous and recommended approach.
# ====================================================================



# --- Method A: Using a pre-trained universal classifier ---
# This step is for a quick check, but the accuracy may not be as good as Method B
# echo "--- Method A: Using pre-trained classifier ---"

# wget -q https://data.qiime2.org/2020.2/common/silva-132-99-nb-classifier.qza
# qiime feature-classifier classify-sklearn \
#   --i-classifier silva-132-99-nb-classifier.qza \
#   --i-reads rep-seq.qza \
#   --o-classification taxonomy_pretrained.qza
# qiime metadata tabulate \
#   --m-input-file taxonomy_pretrained.qza \
#   --o-visualization taxonomy_pretrained.qzv

# --- Method B: Build and use a custom V4-V5 classifier (Strongly Recommended) ---
echo "--- Method B: Build and use a custom V4-V5 classifier ---"

# 1. define primers (should be changed) !!!
FWD_PRIMER="GTGCCAGCMGCCGCGGTAA"
REV_PRIMER="CCGTCAATTCMTTTGAGTTT"

# 2. download SILVA database
if [ ! -f "SILVA_132_QIIME_release/rep_set/rep_set_16S_only/99/silva_132_99_16S.fna" ]; then
  echo "dowload SILVA 132..."
  wget -q https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_132_release.zip
  unzip Silva_132_release.zip
fi

# 3. Import SILVA database to QIIME 2
echo "Importing SILVA sequences..."
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path SILVA_132_QIIME_release/rep_set/rep_set_16S_only/99/silva_132_99_16S.fna \
  --output-path silva_132_99_16S.qza

echo "Importing SILVA taxonomy..."
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path SILVA_132_QIIME_release/taxonomy/16S_only/99/taxonomy_7_levels.txt \
  --output-path silva_132_99_16S_ref_taxonomy.qza

# 4. extract V4-V5 region according to primers
# 200-600 makes sure the cut V4-V5 region is valid
echo "extract V4-V5 region..."
nohup qiime feature-classifier extract-reads \
  --i-sequences silva_132_99_16S.qza \
  --p-f-primer $FWD_PRIMER \
  --p-r-primer $REV_PRIMER \
  --o-reads silva_132_99_16S_ref_seq.qza \
  --p-min-length 200 \
  --p-max-length 600 &>extract_reads_log.txt &                    

wait 

# 5. train classifier 
echo "train classifier  (may require hours)..."
nohup qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads silva_132_99_16S_ref_seq.qza \
  --i-reference-taxonomy silva_132_99_16S_ref_taxonomy.qza \
  --o-classifier silva_132_99_16S_v4-v5_nb_classifier.qza &> train_silva_classifier_full_log.txt &       #?

wait

echo "--- Use custom classifier to assign taxonomy to ASVs ---"
# 6. Use custom classifier
qiime feature-classifier classify-sklearn \
  --i-classifier silva_132_99_16S_v4-v5_nb_classifier.qza \
  --p-n-jobs 16 \
  --i-reads rep-seq.qza \
  --o-classification taxonomy_customized.qza

# 7. Visualize classification results
qiime metadata tabulate \
  --m-input-file taxonomy_customized.qza \
  --o-visualization taxonomy_customized.qzv

# 8. Generate taxonomic bar plots
# Note: The rarefied table is correctly used here
# because all samples have the same depth, facilitating visual comparison.
qiime taxa barplot \
  --i-table core-metrics-results/rarefied_table.qza \
  --i-taxonomy taxonomy_customized.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization taxa-bar-plots_customized.qzv


echo "--- Step 4: Taxonomic Classification Complete ---"
echo "Outputs:"
echo "1. silva_132_99_16S_v4-v5_nb_classifier.qza (Your own classifier!)"
echo "2. taxonomy_customized.qza (Final taxonomic classification results)"
echo "Visualizations:"
echo "taxa-bar-plots_customized.qzv (Taxonomic stacked bar plots)"
"