#!/bin/bash


# ====================================================================
# Script 6: Data Export
#
# Objective: Export key QIIME 2 artifacts (Feature table, Taxonomy)
#          to common .biom and .tsv formats.
# ====================================================================


OUTPUT_DIR="exported_data"
mkdir -p $OUTPUT_DIR

# --- 1. Export rarefied feature table and taxonomy ---
echo "--- Exporting feature table and taxonomy ---"
# Export rarefied table (used for visualization)
qiime tools export \
  --input-path core-metrics-results/rarefied_table.qza \
  --output-path $OUTPUT_DIR/rarefied

# Export taxonomy
qiime tools export \
  --input-path taxonomy_customized.qza \
  --output-path $OUTPUT_DIR

# --- 2. Merge feature table and taxonomy (biom) ---
echo "--- Merging taxonomy into BIOM file ---"
cp $OUTPUT_DIR/taxonomy.tsv $OUTPUT_DIR/biom-taxonomy.tsv

# Automatically replace header
# biom requires Header of taxonomy.tsc to be in '#OTUID', 'ID', 'taxonomy', 'confidence'
sed -i '1s/#Feature ID\tTaxon\tConfidence/#OTUID\tID\ttaxonomy\tconfidence/' $OUTPUT_DIR/biom-taxonomy.tsv

# Add metadata (taxonomy) to the .biom file
biom add-metadata \
  -i $OUTPUT_DIR/rarefied/feature-table.biom \
  -o $OUTPUT_DIR/rarefied/table-with-taxonomy.biom \
  --observation-metadata-fp $OUTPUT_DIR/biom-taxonomy.tsv \
  --sc-separated taxonomy

# Convert .biom to .tsv
biom convert \
  -i $OUTPUT_DIR/rarefied/table-with-taxonomy.biom \
  -o $OUTPUT_DIR/rarefied/table-with-taxonomy.tsv \
  --to-tsv \
  --header-key taxonomy

# --- 3. Automatically export all taxonomic levels (L2-L7) ---

echo "--- Looping to export all taxonomic levels (L2-L7) ---"

for i in 2 3 4 5 6 7; do
  LEVEL_DIR="$OUTPUT_DIR/exported_L${i}"
  mkdir -p $LEVEL_DIR

  echo "Processing Level $i..."
  
  # 1. Collapse to L$i
  qiime taxa collapse \
    --i-table core-metrics-results/rarefied_table.qza \
    --i-taxonomy taxonomy_customized.qza \
    --p-level $i \
    --o-collapsed-table $LEVEL_DIR/table-l$i.qza
    
  # 2. Export to .biom
  qiime tools export \
    --input-path $LEVEL_DIR/table-l$i.qza \
    --output-path $LEVEL_DIR
    
  # Convert .biom to .tsv
  biom convert \
    -i $LEVEL_DIR/feature-table.biom \
    -o $LEVEL_DIR/L${i}-table.tsv \
    --to-tsv
    
  # Clean up header (remove biom comment line)
  tail -n+2 $LEVEL_DIR/L${i}-table.tsv | sed 's/^#OTU ID/Taxon/' > $LEVEL_DIR/L${i}_final_table.txt
  
done > export_all_levels.log 2>&1


echo "--- Step 6: Data Export Complete ---"
echo "Outputs: exported_data/ folder"
echo "Contains rarefied/table-with-taxonomy.tsv (ASV + Taxonomy)"
echo "And exported_L*/L*_final_table.txt (summary tables for each level)"