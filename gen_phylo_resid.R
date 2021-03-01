# For more usage information
# >> Rscript gen_phylo_resid.R -h

# INSTALL PACKAGE
list.of.packages <- c('argparse', 'phytools', 'ape', 'taxize')

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.us.r-project.org")

# LOAD PACKAGES
# all warnings/messages are suppressed
suppressMessages(suppressWarnings(library(argparse)))
suppressMessages(suppressWarnings(library(phytools)))
suppressMessages(suppressWarnings(library(ape)))
suppressMessages(suppressWarnings(library(taxize)))

# PARSE ARGUMENTS
parser <- ArgumentParser()
parser$add_argument("-d", "--dependent", type="character", default="dependent", help="name of column containing dependent variable")
parser$add_argument("-i", "--independent", type="character", default="independent", help="name of column containing independent variable")
parser$add_argument("-p", "--path", type="character", default="", help="path to data file")
parser$add_argument("-r", "--rows", type="integer", default=-1, help="number of rows in data file")
parser$add_argument("-l", "--latin", type="character", default="latin_names", help="name of column containing latin names")

argv <- parser$parse_args()


### read the data from the data file, throw error if invalid path
tryCatch(
    expr = {
        data <- read.csv(argv$path)
    },
    error = function(e) { 
    	cat("Invalid Path. Please enter a valid path as argument: -p PATH\n")
	quit()
    },
    warning = function(w) {
    	cat("Invalid Path. Please enter a valid path as argument: -p PATH\n")
    	quit()
    })

### if we have mentioned the number of rows, trim the data
if (argv$rows > 0) {
   data = data[1:argv$rows, ]
}

### set the row names to the species latin name
m_species <- data[,which(colnames(data)==argv$latin)]
rownames(data) = c(m_species)

### obtain the classification information of each species on the list
### from the ncbi database
m_class <- classification(m_species, db='ncbi')

### use the classification information to create a phylogenetic tree
tree <- class2tree(m_class)$phylo

### add branch lengths to the phylogenetic tree
phy <- compute.brlen(tree, method = "Grafen", power = 1)  

### To visualize the tree
### plot the phylogenetic tree with branch lengths
# plot(phy, no.margin=TRUE, edge.width=2)

### X independent variable (eg. brain volume log_10)
X <- cbind(data[,which(colnames(data)==argv$independent)])
rownames(X) = c(m_species)

### Y is the dependent variable (eg. ratio of cerebellum volume to vermis volume)
Y <- cbind(data[,which(colnames(data)==argv$dependent)])
rownames(Y) = c(m_species)

### generate residuals for the dependent variable
m_residuals <- phyl.resid(phy, X, Y, method="BM")$resid
colnames(m_residuals) <- c(paste("residuals","_",argv$dependent))

### save residuals_data along with the rest of the data
f_data <- merge(data, m_residuals, by=0, all=TRUE)[, -c(1)]
write.csv(f_data, argv$path, row.names=FALSE)

