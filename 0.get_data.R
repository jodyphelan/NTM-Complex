metadata_url <- "https://data.gtdb.ecogenomic.org/releases/release232/232.0/bac120_metadata_r232.tsv.gz"
tree_url <- "https://data.gtdb.ecogenomic.org/releases/release232/232.0/bac120_r232.tree"

# Download the metadata from GTDB if they don't already exist
if (!file.exists(file.path("input_data", "bac120_metadata.tsv.gz"))) {
  download.file(metadata_url, destfile = file.path("input_data", "bac120_metadata.tsv.gz"))
}

# Download the tree file from GTDB if it doesn't already exist
if (!file.exists(file.path("input_data", "bac120.tree"))) {
  download.file(tree_url, destfile = file.path("input_data", "bac120.tree"))
}
