# This script subsets the gtdb tree (with all bacteria) to just the Mycobacterial clade

library(ape)
library(data.table)


gtdb_data <- fread(file.path("processed_data", "gtdb_mycobacterium_representative_metadata.csv"), sep = ",", header = TRUE)

# read in the bac120 tree
raw_tree <- read.tree(file.path("input_data", "bac120.tree"))
# remove annoying "RS_" and "GB_" prefixes from the tip labels
raw_tree$tip.label <- gsub("^(RS_|GB_)", "", raw_tree$tip.label)

# get the node numbers for the tips that correspond to the Mycobacterium accessions
nodes_to_keep <- raw_tree$tip.label %in% gtdb_data$accession %>% which()

# subset the tree to only include the Mycobacterium tips
mycobacterium_tree <- drop.tip(raw_tree, raw_tree$tip.label[-nodes_to_keep])


# Check tree structure without plotting tips
plot(mycobacterium_tree, type = "fan", show.tip.label = FALSE)


# write the Mycobacterium tree to a new file
write.tree(mycobacterium_tree, file = file.path("processed_data", "mycobacterium_tree.nwk"))

