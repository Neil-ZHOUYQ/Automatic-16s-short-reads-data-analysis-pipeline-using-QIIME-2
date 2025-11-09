# Automatic-16s-short-reads-data-analysis-pipeline-using-QIIME-2


This repository contains a modular set of bash scripts for a complete 16S rRNA amplicon sequencing analysis workflow. The pipeline is built using QIIME 2 (qiime2-2020.2) and is designed to be reproducible, modular, and easy to follow.  

## Workflow Summary

This pipeline goes through the processes of quality control, denoising, assigning taxonomy, caculating core diversity metrics and exporting results to .tsv or .txt formats. processes raw, paired-end FASTQ data into publication-ready statistical analyses and tables.  


## Requirements

QIIME 2: This pipeline was developed using qiime2-2020.2. The commands may vary with other versions.  
biom-format: This tool is required for the final data export steps.

## Input Files

Raw FASTQ Files: Paired-end (_R1.fastq.gz and _R2.fastq.gz) sequencing files for all your samples. 
sample-metadata.tsv: sample-id, disease_type, subgroup...
manifest.txt


## License
This project is licensed under the MIT License.

