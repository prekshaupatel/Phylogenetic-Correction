require(phytools); require(geiger); require(nlme); require(evomap); require(taxize)

### set the path to the location of the data file (.csv)
input = "resid_module2.csv"

### set col_latin_names to the column number containing the 
### latin names of the species
col_latin_names <- 2

### set col_independent to the column number of the independent variable
### eg. the log_10 brain volume
col_independent <- 14

### set col_dependent to the column number of the dependent variable
### eg. ratio of cerebellum volume to vermis volume
col_dependent <- 11


### read the data from the data file
input_data <- read.csv(input)

### set the row names to the species latin name
m_species <- input_data[,col_latin_names]
rownames(input_data) = c(input_data[,col_latin_names])


### obtain the classification information of each species on the list
### from the ncbi database
m_class <- classification(m_species, db='ncbi')

### use the classification information to create a phylogenetic tree
tree <- class2tree(m_class)$phylo

### add branch lengths to the tree
phy <- compute.brlen(tree, method = "Grafen", power = 1)  ### replot tree

### extract independent and dependent variable data
data <- cbind(input_data[,col_dependent], input_data[,col_independent])
colnames(data)<-c("Dependent","Independent")
rownames(data) = c(m_species)

### match tree and data
tree<-treedata(tree,data,sort=T,warnings=T)$phy
data<-as.data.frame(treedata(tree,data,sort=T,warnings=T)$data)

### add column and row labels to data
colnames(data)<-c("Dependent","Independent")
rownames(data) = c(m_species)

### label groups
carnivora <- input_data[input_data$Group == "Carnivora", 1]
rodents <- input_data[input_data$Group == "Rodentia", 1]
ungulates <- input_data[input_data$Group == "Ungulates", 1]
primates <- input_data[input_data$Group == "Primate", 1]
other <- input_data[input_data$Group == "Other", 1]

grpS<-rep("O",length(rownames(data)))
grpS[primates]<-"P"
grpS[ungulates]<-"U"
grpS[rodents]<-"R"
grpS[carnivora]<-"C"
grpS<-as.factor(grpS) 
names(grpS)<-rownames(data)

### Baseline Model
Model<-model.matrix(as.formula(Dependent~Independent),data)

### Model with five groups: primates, carnivora, rodentia, ungulates, others
### (Differences in slopes)
Model_S<-model.matrix(as.formula(Dependent~grpS:Independent),data) 

### pANCOVA with phylogenetic variance-covariance matrix as covariate 
gls.ancova(Dependent~Independent,vcv(tree),Model,Model_S)

gls.ancova(Dependent~Independent,diag(60),Model,Model_S)





