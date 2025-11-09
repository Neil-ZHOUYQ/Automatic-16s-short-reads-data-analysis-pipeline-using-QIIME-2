#!/bin/bash

# Before running the QIIME2 pipeline, manifest and metadata files should be prepared

# ====================================================================
# script 1：data import and initial QC 
#
# Target：import FASTQ to QIIME2 object(.qza) and visualize data quaslity 
#       to select DADA2 parameter
# ====================================================================

echo "--- Step 1: Importing Data ---"

# Use Phred33 format to import fastq with paired ends
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path pe-33-manifest.txt \                             # script 0 output
  --output-path demux.qza \
  --input-format PairedEndFastqManifestPhred33

echo "---Step 2: Summarizing data"
# The step determines DADA2 paremeter
qiime demux summarize \
  --i-data demux.qza \
  --o-visualization demux.qzv

echo "--- Script 1:Data import and initial QC is completed ---"
echo "Output:demux.qza"
echo "Visualization: demux.qzv"
echo "Next: Open demux.qzv in QIIME 2 View(view.qiime2.org)"
echo "View 'Interactive Quality Plot' to determine parameters '--p-trunc-len-f', '--p-trunc-len-r'"


