library(phytools)
library(ape)
library(taxize)

### set the path to the location of the data file (.csv)
path <- "/Users/prekshapatel/Desktop/data_module2.csv"

### set the path to output files destination
output <- "resid_module2.csv"

### set col_latin_names to the column number containing the 
### latin names of the species
col_latin_names <- 2

### set col_independent to the column number of the independent variable
### eg. the log_10 brain volume
col_independent <- 17

### set col_dependent to the column number of the dependent variable
### eg. ratio of cerebellum volume to vermis volume
col_dependent <- 15


### read the data from the data file
data <- read.csv(path) 

### set the row names to the species latin name
m_species <- data[,col_latin_names]
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
X <- cbind(data[,col_independent])
rownames(X) = c(m_species)

### Y is the dependent variable (eg. ratio of cerebellum volume to vermis volume)
Y <- cbind(data[,col_dependent])
rownames(Y) = c(m_species)

### generate residuals for the dependent variable
m_residuals <- phyl.resid(phy, X, Y, method="BM")$resid
colnames(m_residuals) <- c(paste("residuals","_",colnames(data)[col_dependent]))

### save residuals_data along with the rest of the data
f_data <- merge(data, m_residuals, by=0, all=TRUE)[, -c(1)]
write.csv(f_data, output, row.names=FALSE)


