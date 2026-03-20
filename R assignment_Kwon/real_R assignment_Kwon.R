
# 1. Load libraries

library(dplyr)
library(tidyr)
library(readr)

#====================================
###dplyr provides functions such as:

  #filter() → choose rows based on conditions

  #select() → choose columns

  #arrange() → sort rows

  #mutate() → create new variables

  #summarize() → calculate summary statistics


# 2. Load data

genotypes <- read_tsv("https://raw.githubusercontent.com/EEOB-BioData/BCB5460_Spring2026/main/assignments/UNIX_Assignment/fang_et_al_genotypes.txt")

snp_pos <- read_tsv("https://raw.githubusercontent.com/EEOB-BioData/BCB5460_Spring2026/main/assignments/UNIX_Assignment/snp_position.txt")


# 3. Inspect data

head(genotypes) #first row
dim(genotypes) #dimenstion (column and row)
colnames(genotypes) #column names

head(snp_pos)
dim(snp_pos)
colnames(snp_pos)

#============================
### Both files have "SNP_ID".But Genoypes have SNP_ID as rows and SNP_Pos have them in one column. Nee to transpose one of them so I can join two files.


# 4. Transpose genotype data

## Transpose: All columns go to in "SNP_ID" line except Sample_ID, Group, JG_OTU
geno_long <- genotypes %>%
  pivot_longer(cols = -c(Sample_ID, JG_OTU, Group),names_to = "SNP_ID", values_to = "Genotype")
               

# 5. Prepare SNP position table
snp_info <- snp_pos %>% select(SNP_ID, Chromosome, Position)


# 6. Join genotype and position data
combined_data <- inner_join(snp_info, geno_long, by = "SNP_ID")


# 7. Separate maize and teosinte groups
maize_groups <- c("ZMMIL", "ZMMLR", "ZMMMR")
teosinte_groups <- c("ZMPBA", "ZMPIL", "ZMPJA")

maize_data <- combined_data %>% filter(Group %in% maize_groups)
teosinte_data <- combined_data %>% filter(Group %in% teosinte_groups)

# 8. Replace missing data
maize_data[maize_data == "N"] <- "?"
teosinte_data[teosinte_data == "N"] <- "?"

# 9. Function to create chromosome files
write_chr_files <- function(data, group_name){
  
  lapply(1:10, function(chr){
    
    # 1. filter chromosomes
  chr_subset <- data %>% dplyr::filter(Chromosome == as.character(chr))
    
    # 2. Pivot Wider for making format more readable
    # leave SNP data, make Sample_ID as colum name, make Genotype as value
  chr_wide <- chr_subset %>%
  select(SNP_ID, Chromosome, Position, Sample_ID, Genotype) %>%
  pivot_wider(names_from = Sample_ID, values_from = Genotype)
    
    ## --- 오름차순 파일 생성 ---
    inc <- chr_wide %>% arrange(as.numeric(Position))
    write.table(inc, paste0(group_name, "_chr", chr, "_inc.txt"), 
                sep = "\t", quote = FALSE, row.names = FALSE)
    
    ## --- 내림차순 파일 생성 ---
    dec <- chr_wide %>% arrange(desc(as.numeric(Position)))
    
    # 내림차순일 때는 ?를 -로 바꾸기
    dec[dec == "?"] <- "-"
    
    write.table(dec, paste0(group_name, "_chr", chr, "_dec.txt"), 
                sep = "\t", quote = FALSE, row.names = FALSE)
  })
}


# 10. Generate all files
write_chr_files(maize_data, "maize")
write_chr_files(teosinte_data, "teosinte")

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
