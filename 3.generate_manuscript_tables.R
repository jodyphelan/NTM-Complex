library(data.table)
library(dplyr)

# read in the GTDB metadata, the combined literature data, and the manually curated complex data
gtdb_data <- fread(file.path("processed_data", "gtdb_mycobacterium_representative_metadata.csv"), sep = ",", header = TRUE)
combined_literature_data <- fread(file.path("input_data", "literature_data.csv"), sep = ",", header = TRUE)
manual_complex_data <- fread(file.path("input_data", "manual_complex_pick.csv"), sep = ",", header = TRUE)


# drop the "accession" column from the literature and manual complex data
manual_complex_data <- manual_complex_data %>% select(-accession)


# merge the three datasets by the "species" column
tmp_merged_data1 <- merge(gtdb_data, combined_literature_data, by = "species", all.x = TRUE)
merged_data <- merge(tmp_merged_data1, manual_complex_data, by = "species", all.x = TRUE, suffixes = c("_literature", "_gtdb"))

# get the number of unique complex names from the literature column remove NA values
complexes_analysed <- merged_data %>% select(complex_literature) %>% distinct() %>% filter(!is.na(complex_literature))

# Adding columns descibing the type for table 1
# Historical - it will have a value in the literature column
# Retained - it will have the same value in the literature and gtdb columns
# New - it will have a value in the gtdb column but not in the literature or when the gtdb complex name is different from the literature complex name
# Dropped - it will have a value in the literature column but not in the gtdb column
merged_data$historical <- !is.na(merged_data$complex_literature) 
merged_data$retained <- merged_data$complex_literature == merged_data$complex_gtdb
merged_data$new <- (is.na(merged_data$complex_literature) & !is.na(merged_data$complex_gtdb)) |
  (!is.na(merged_data$complex_literature) & !is.na(merged_data$complex_gtdb) & (merged_data$complex_literature != merged_data$complex_gtdb)) 
merged_data$dropped <- !is.na(merged_data$complex_literature) & is.na(merged_data$complex_gtdb)

fwrite(merged_data, file = file.path("manuscript_tables", "supplementary_table_1.csv"), row.names = FALSE)


# count the number of historical, retained, and new complexes by the complex as defined in the complex_gtdb column
historical_counts <- merged_data %>% group_by(complex_literature) %>%
  summarise(historical_count = sum(historical, na.rm = TRUE))%>%
  ungroup()

retained_and_new_counts <- merged_data %>% group_by(complex_gtdb) %>%
  summarise(
    retained_count = sum(retained, na.rm = TRUE),
    new_count = sum(new, na.rm = TRUE)
    ) %>%  ungroup()

# merge the two counts by the complex as defined in the complex_gtdb column
table1 <- merge(historical_counts, retained_and_new_counts, by.x = "complex_literature", by.y = "complex_gtdb", all = TRUE)
# remove the NA rows from the table
table1 <- table1 %>% filter(!is.na(complex_literature))

# write the table to a new file
fwrite(table1, file = file.path("manuscript_tables", "table_1.csv"), row.names = FALSE)

# remove species with an "_" in the name or that are "Mycobacterium sp[0-9]+" from the merged data for table 2
named_species_data <- merged_data %>%
  filter(!grepl("_", species)) %>%
  filter(!grepl("Mycobacterium sp[0-9]+", species))

# get the species names that are new for each complex
new_species_by_complex <- named_species_data %>%
  filter(new) %>%
  group_by(complex_gtdb) %>%
  summarise(new_species = paste(species, collapse = ", ")) %>%
  ungroup()

# get the species names that are dropped for each complex
dropped_species_by_complex <- named_species_data %>%
  filter(dropped) %>%
  group_by(complex_literature) %>%
  summarise(dropped_species = paste(species, collapse = ", ")) %>%
  ungroup()

# get the species names that are retained for each complex
retained_species_by_complex <- named_species_data %>%
  filter(retained) %>%
  group_by(complex_gtdb) %>%
  summarise(retained_species = paste(species, collapse = ", ")) %>%
  ungroup()


# combine the new, dropped, and retained species by complex into a single table
supplementary_table2 <- merge(new_species_by_complex, dropped_species_by_complex, by.x = "complex_gtdb", by.y = "complex_literature", all = TRUE)
supplementary_table2 <- merge(supplementary_table2, retained_species_by_complex, by = "complex_gtdb", all = TRUE)

# write the table to a new file
fwrite(supplementary_table2, file = file.path("manuscript_tables", "supplementary_table_2.csv"), row.names = FALSE)
