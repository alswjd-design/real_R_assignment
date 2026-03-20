# 1. Load libraries
library(dplyr)
#====================================
###dplyr provides functions such as:

  #filter() → choose rows based on conditions

  #select() → choose columns

  #arrange() → sort rows

  #mutate() → create new variables

  #summarize() → calculate summary statistics


#===== Bring assignment file (in terminal)
#git clone https://github.com/EEOB-BioData/BCB5460_Spring2026.git
#setwd("C:/Users/0906s/Downloads/R class in ISU")
#getwd()


# 2. Load data

genotypes_2 <- read_csv("https://raw.githubusercontent.com/EEOB-BioData/BCB5460_Spring2026/main/assignments/UNIX_Assignment/fang_et_al_genotypes.txt")

genotypes <- read.delim(
  "https://raw.githubusercontent.com/EEOB-BioData/BCB5460_Spring2026/main/assignments/UNIX_Assignment/fang_et_al_genotypes.txt",
  sep = "\t",
  stringsAsFactors = FALSE
)

snp_pos <- read.delim(
  "https://raw.githubusercontent.com/EEOB-BioData/BCB5460_Spring2026/main/assignments/UNIX_Assignment/snp_position.txt",
  sep = "\t",
  stringsAsFactors = FALSE
)
#===================================================
### read.delim() reads tab-separated text files
###sep="\t" tells R that columns are separated by tabs
###stringsAsFactors = FALSE prevents automatic conversion to factors
  
# 3. Inspect data
head(genotypes) #first row
dim(genotypes) #dimenstion (column and row)
colnames(genotypes) #column names

head(snp_pos)
dim(snp_pos)
colnames(snp_pos)
#============================
### genotypes file has "SNP_ID", "Group", Sample names... in column and has SNPs in rows.
### snp_pos has Sample names in rows.
### For joining, both file should have same column. So we need to do Transpose.

# 4. Transpose genotype data
## Extract Sample_ID and Group we need for joining files
group_info <- genotypes %>% select(Sample_ID, Group)
  ### Validate
  head(group_info)
## Remove first three columns to only get SNP genotype data
  geno_data <- genotypes %>% select(-(Sample_ID:Group))
  ### Validate
  dim(geno_data)
  head(geno_data[,1:5])

## Transpose
geno_trans <- geno_data %>% t() %>% as.data.frame()
  ### t() performs transposition:rows → columns / columns → rows, So individuals (rows) → columns / SNPs (columns) → rows
  ### as.data.frame() convert objects like vectors, lists, matrices, arrays, or factors into a data frame.

### SNP_ID is a standard for joining. After transpose, row names are SNP names. So recover SNP IDs (from row to column)
geno_trans$SNP_ID <- rownames(geno_trans)

## Move SNP_ID to first column
geno_trans <- geno_trans %>% select(SNP_ID, everything())


## Recover sample names:t()를 사용하면 column 이름이 V1 V2 V3 ...로 바뀝니다.그래서 원래 sample 이름을 다시 지정합니다.
colnames(geno_t)[-1] <- genotypes$Sample_ID
  ### Validate
  colnames(geno_t)[1:10]

# 5. Prepare SNP position table
snp_pos <- snp_pos %>%
  rename(SNP_ID = SNP_ID,
         Chromosome = Chromosome,
         Position = Position)

# 6. Join genotype and position data
joined_data <- inner_join(snp_pos, geno_trans, by = "SNP_ID")
###Position이 character이면 sorting이 불가능합니다.그래서 numeric으로 변환합니다.
joined_data$Position <- as.numeric(joined_data$Position)

# 7. Separate maize and teosinte groups
maize_groups <- c("ZMMIL","ZMMLR","ZMMMR")
maize_samples <- group_info %>%
  filter(Group %in% maize_groups) %>%
  pull(Sample_ID)

teosinte_groups <- c("ZMPBA","ZMPIL","ZMPJA")
teosinte_samples <- group_info %>%
  filter(Group %in% teosinte_groups) %>%
  pull(Sample_ID)

maize <- joined_data %>%
  select(SNP_ID, Chromosome, Position, all_of(maize_samples))
teosinte <- joined_data %>%
  select(SNP_ID, Chromosome, Position, all_of(teosinte_samples))
  ## Validate
  head(maize)
  head(teosinte)

# 8. Replace missing data
maize[maize == "N"] <- "?"
teosinte[teosinte == "N"] <- "?"

# 9. Function to create chromosome files
write_chr_files <- function(data, group_name){
  
  lapply(1:10, function(chr){
    
    chr_data <- data %>%
      filter(Chromosome == chr)
    
## Increasing order
    inc <- chr_data %>%
      arrange(Position)
    
    write.table(inc,
                paste0(group_name, "_chr", chr, "_inc.txt"),
                sep = "\t",
                quote = FALSE,
                row.names = FALSE)
    
## Decreasing order
    dec <- chr_data %>%
      arrange(desc(Position))
    
    dec[dec == "?"] <- "-"
    
    write.table(dec,
                paste0(group_name, "_chr", chr, "_dec.txt"),
                sep = "\t",
                quote = FALSE,
                row.names = FALSE)
    
  })
}

# 10. Generate all files
write_chr_files(maize, "maize")
write_chr_files(teosinte, "teosinte")

# 11. Validation
getwd()
list.files()


#===========================================

#Visualization
#1
library(tidyverse)

#2
geno_data <- genotypes %>%
  select(-(Sample_ID:Group))

geno_trans <- geno_data %>%
  t() %>%
  as.data.frame()

geno_trans <- geno_trans %>%
  mutate(SNP_ID = rownames(.)) %>%
  select(SNP_ID, everything())

colnames(geno_trans)[-1] <- genotypes$Sample_ID

joined_data <- snp_pos %>%
  filter(!Position %in% c("unknown", "multiple")) %>%
  mutate(Position = as.numeric(Position)) %>%
  inner_join(geno_trans, by = "SNP_ID")

#3
geno_long <- joined_data %>%
  pivot_longer(
    cols = -c(SNP_ID, Chromosome, Position),
    names_to = "Sample_ID",
    values_to = "Genotype"
  )
