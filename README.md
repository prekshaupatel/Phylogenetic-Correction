# Phylogenetic-Correction

To generate residuals:

* Run the **phylo_corr.R** script in RStudio after changing the variable as commented
* Run the **gen_phylo_resid.R** script on Terminal. To get more information 

           >> Rscript gen_phylo_resid.R -h
           
  For example, 
           
           >> Rscript gen_phylo_resid.R -p ~\Desktop\data.csv -i independent_var -d dependent_var -l latin_names -r 30
           
  If the flags are not defined, the default values are **d** = "dependent", **i** = "independent", **l** = "latin", **r** = all rows

          


## Issues Encountered

What to do if you encounter the following errors in phylo_corr.R:

**Error:**
```R
>> rownames(data) = c(m_species)
Error in `.rowNamesDF<-`(x, value = value) : 
duplicate 'row.names' are not allowed
In addition: Warning message:
non-unique value when setting 'row.names': ‘ ’
``` 
**Solution:** <br>
  This indicates that you have two columns with the same species names. If that is not the case, ensure that your csv does not have extra blank rows. Change the following row to 
  
 ```diff
 - data <- read.csv(path) 
 + data <- read.csv(path) [1:index, ]
 ```
 Where index is the number of rows of data (excluding the header) in your data file.
 <br><br><br>
 **Error:**
```R
>> m_residuals <- phyl.resid(phy, X, Y, method="BM")$resid
Error in X[tree$tip.label, ] : subscript out of bounds
```
**Solution:** <br>
This indicates that the species in your data do not match the species in the tree. To match these run the following lines of code
```R
>>  m_species = tree$tip.label
>> rownames(data) = c(m_species)
>> rownames(X) = c(m_species)
>> rownames(Y) = c(m_species)
>> m_residuals <- phyl.resid(phy, X, Y, method="BM")$resid
```
Continue running the remaining code.
<br>
Another solution would be to update the .csv file such that the species column is equal to the tree$tip.label list.


 
 
