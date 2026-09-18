get_first_and_last_nodes_in_range <- function(tree, leaf_names) {
    # This function takes a phylogenetic tree and a list of leaf names as 
    # input and returns the first and last nodes in the range of those 
    # leaf names in the tree. 
    # For example if you pass in (Node 3, Node 4, Node 5) it will return (Node 3, Node 5)
    #         ┌── Node 1
    #     ┌───┤
    #     │   └── Node 2
    # ────┤
    #     │   ┌── Node 3
    #     └───┤
    #         └── Node 4
    #         │
    #         └── Node 5
  
    # get node in tree which contains all the accessions in tmp
    node <- getMRCA(tree, leaf_names)
    
    # extract the clade corresponding to that node
    subset_tree <- extract.clade(tree, node)
    
    # get the tip labels of the subset tree
    tip_labels <- subset_tree$tip.label
    
    # find the first and last nodes in the range of tip labels
    first_node <- tip_labels[1]
    last_node <- tip_labels[length(tip_labels)]
    
    return(c(first_node,  last_node))
}

range_template <- r"(
DATASET_RANGE
SEPARATOR COMMA
DATASET_LABEL,%s
COLOR,#ffff00
RANGE_COVER,clade
DATA
)"

create_itol_range_config <- function(input_ranges,name,colour_conf) {
    range_strings<-c()
    for (cmpx in names(input_ranges)) {
        tmp<-input_ranges[[cmpx]]
        range_strings <- c(range_strings, paste(tmp[1], tmp[2], colour_conf[[cmpx]], colour_conf[[cmpx]], "#000000", "solid", cmpx, sep = ","))
    }
    config_string <- sprintf(range_template, name)
    return(paste(config_string, paste(range_strings, collapse = "\n"), sep = "\n"))
}

colour_strip_template <- r"(
DATASET_COLORSTRIP
SEPARATOR COMMA
DATASET_LABEL,%s
COLOR,#ff0000

LEGEND_TITLE,%s
LEGEND_SHAPES,%s
LEGEND_LABELS,%s
LEGEND_COLORS,%s

DATA
)"

create_itol_colour_strip_config <- function(leaf_names,values,name,colour_conf) {
    empty_vals = which(values == "")
    leaf_names <- leaf_names[-empty_vals]
    values <- values[-empty_vals]
    feature_names <- unique(values)
    legend_shapes <- rep(1, length(feature_names))
    legend_labels <- feature_names
    legend_colors <- sapply(feature_names, function(x) colour_conf[[x]])
    config_string <- sprintf(colour_strip_template, name, name, paste(legend_shapes, collapse = ","), paste(legend_labels, collapse = ","), paste(legend_colors, collapse = ","))
    
    data_strings<-c()
    
    for (i in seq_along(leaf_names)) {
        if (values[i] %in% names(colour_conf)) {
            data_strings <- c(data_strings, paste(leaf_names[i], colour_conf[[values[i]]], sep = ","))
        }
    }
    
    
    return(paste(config_string, paste(data_strings, collapse = "\n"), sep = "\n"))
}



text_label_template <- r"(
DATASET_TEXT
SEPARATOR COMMA
DATASET_LABEL,%s
COLOR,#000000

DATA
)"

create_itol_text_label_config <- function(leaf_names, labels, name) {
    config_string <- sprintf(text_label_template, name)
    
    data_strings <- c()
    for (i in seq_along(leaf_names)) {
        data_strings <- c(data_strings, paste(leaf_names[i], labels[i], '-1','#000000','normal',1,0, sep = ","))
    }
    
    return(paste(config_string, paste(data_strings, collapse = "\n"), sep = "\n"))
}