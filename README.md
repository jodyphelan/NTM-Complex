# Complexes of Mycobacterium

All the script in this directory are used to generate files for the complex paper.

## Input data

### Data from GTDB 
Data is downloaded from https://data.gtdb.aau.ecogenomic.org/releases/latest/

- bac120.tree - This is the tree with all the bacterial species. 
- bac120_metadata.tsv.gz - This is the metadata for all the bacterial genomes.

### Literature data

Complexes were extracted from three papers and put into the 'literature_data.csv' file.

- Tortoli - https://pubmed.ncbi.nlm.nih.gov/17064273/
- Fedrizzi - https://pubmed.ncbi.nlm.nih.gov/28345639/
- Romagnoli - https://pubmed.ncbi.nlm.nih.gov/38322314/

## Other files

manual_complex_pick.csv - This was created manually by looking at itol and picking what I thought was the best branch to represent the complexes based on clustering the species from the literature... very scientific :)

## Analysis files

There are a few R scripts and bash that are used to generate the files for the paper. They are labelled in order that they shoud be run.

## Outputs
Hopefully with the tree and itol outputs you should be able to reproduce the figures in the paper. 