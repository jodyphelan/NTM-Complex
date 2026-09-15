# This script subsets the GTDB metadata to only include Mycobacterium representative genomes and writes a new file 
#with only the accession and species columns.
# Don't run this whole script all at once, for some reason it doesn't work.

library(data.table)
library(tidyverse)


# I'm using file.path because then it works on both windows and mac/linux. 
gtdb_data <- fread(file.path("input_data", "bac120_metadata.tsv.gz"))


# Extract the genus from the GTDB taxonomy column:
# 1. split the taxonomy string by semicolon
# 2. extract the 6th element (genus) from the resulting list with g__ removed from the start
gtdb_data$genus <- gtdb_data$gtdb_taxonomy %>% strsplit(";") %>% sapply(function(x) sub("^g__", "", x[6]))

# subset the data to only include rows where the genus is "Mycobacterium"
mycobacterium_data <- gtdb_data[gtdb_data$genus == "Mycobacterium", ]

# create a "clean" species column by extracting the 7th element (species) from the GTDB taxonomy with the s__ removed from the start
mycobacterium_data$species <- mycobacterium_data$gtdb_taxonomy %>% strsplit(";") %>% sapply(function(x) sub("^s__", "", x[7]))

# then subset even further to only include rows from representative genomes
representative_data <- mycobacterium_data[mycobacterium_data$gtdb_representative == 't', ]

# write a subset of columns from the representative subset to a new file
# columns to keep: accession, species
# also remove the annoying "RS_" and "GB_" prefixes from the accession column
representative_data_column_subset <- representative_data[, .(accession, species)]
representative_data_column_subset$accession <- gsub("^(RS_|GB_)", "", representative_data_column_subset$accession)

output_file_path <- file.path("processed_data", "gtdb_mycobacterium_representative_metadata.csv")
fwrite(representative_data_column_subset, file = output_file_path, sep = ",", row.names = FALSE, col.names = TRUE)
