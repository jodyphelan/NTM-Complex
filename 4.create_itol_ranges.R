library(ape)
library(dplyr)

# I've defined some of the more complex functions in a separate file to keep this script cleaner
source(file.path("functions.R"))


# This table is read in to extract the accesison -> complex mapping
df<-read.csv(file.path("manuscript_tables", "supplementary_table_1.csv"), header = TRUE, sep = ",")

# These are the colours used for iTOL annotations
colour_conf <- list(
  "M. avium complex" = "#A6CEE3",
  "M. simiae complex" = "#FF7F00",
  "M. scrofulaceum group" = "#B2DF8A",
  "M. terrae complex" = "#6A3D9A",
  "M. chelonae-abscessus complex" = "#E31A1C",
  "M. triviale group" = "#FDBF6F",
  "M. celatum group" = "#1F78B4",
  "M. fortuitum complex" = "#33A02C",
  "M. smegmatis group" = "#CAB2D6",
  "M. leprae group" = "#FB9A99"
)

create_itol_colour_strip_config(df$accession, df$Tortoli, "Tortoli", colour_conf) %>%
  writeLines(file.path("processed_data", "Tortoli_colour_strip.txt"))

create_itol_colour_strip_config(df$accession, df$Fedrizzi, "Fedrizzi", colour_conf) %>%
  writeLines(file.path("processed_data", "Fedrizzi_colour_strip.txt"))

create_itol_colour_strip_config(df$accession, df$Romagnoli, "Romagnoli", colour_conf) %>%
  writeLines(file.path("processed_data", "Romagnoli_colour_strip.txt"))

# Creating the itol colour strip dataset for literature data
create_itol_colour_strip_config(df$accession, df$complex_literature, "complex_literature_colour_strip", colour_conf) %>%
  writeLines(file.path("processed_data", "complex_literature_colour_strip.txt"))

create_itol_colour_strip_config(df$accession, df$complex_gtdb, "complex_gtdb_colour_strip", colour_conf) %>%
  writeLines(file.path("processed_data", "complex_gtdb_colour_strip.txt"))

create_itol_text_label_config(df$accession, df$species, "species_text_labels") %>%
  writeLines(file.path("processed_data", "species_text_labels.txt"))


##### iTOL Range Annotations #####

# get a list of unique complex names from the complex_gtdb column filtering out empty values
complexes_analysed <- (df %>% select(complex_gtdb) %>% filter(complex_gtdb != "") %>% distinct())$complex_gtdb

# Kind of complex here, we set up a list that maps the complex to accessions. 
complex_to_accession_list <- list()
for (complex_name in complexes_analysed) {
  tmp <- df %>%
    filter(complex_gtdb == complex_name) %>%
    select(accession)
  complex_to_accession_list[[complex_name]] <- tmp$accession
}


# The tree is read in to get the right nodes to define the ranges for the iTOL range dataset. 
tree<-read.tree(file.path("processed_data", "mycobacterium_tree.nwk"))

# Loop over each complex and get the first and last nodes in the range of tip labels for that complex
ranges = list()
for (complex_name in complexes_analysed) {
  ranges[[complex_name]] <- get_first_and_last_nodes_in_range(tree, complex_to_accession_list[[complex_name]])
}

# Creating the itol range dataset
create_itol_range_config(ranges, "complex_gtdb_ranges", colour_conf) %>%
  writeLines(file.path("processed_data", "complex_gtdb_ranges.txt"))

