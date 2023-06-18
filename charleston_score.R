setwd("~/Desktop/trinetx")

install.packages("comorbidity")
install.packages("ICD9CM")
install.packages("icd")
library(comorbidity)
library(ICD9CM)
library(icd)

dx_table<- fread("~/Desktop/trinetx/diagnosis.csv")
neoplasm_pts<- read.csv("~/Desktop/trinetx/oncdx_ids.csv")
dx_table<- subset(dx_table, patient_id %in% neoplasm_pts$x)

#icd10
icd10<- dx_table %>% filter(code_system== "ICD-10-CM")
icd10$unique<- paste(icd10$patient_id,icd10$code,sep = "")
icd10 <- icd10 %>% distinct(unique, .keep_all = TRUE)
icd10<- icd10 %>% select(patient_id,code)
icd10<- icd10 %>% group_by(patient_id)
icd10_charleston<- comorbidity(icd10, id= "patient_id", code = "code", map = "charlson_icd10_quan", assign0 = TRUE)

#icd9
icd9<- dx_table %>% filter(code_system== "ICD-9-CM")
icd9$unique<- paste(icd9$patient_id,icd9$code,sep = "")
icd9 <- icd9 %>% distinct(unique, .keep_all = TRUE)
icd9 <- icd9 %>% select(patient_id,code)
icd9 <- icd9 %>% group_by(patient_id)
icd9_charleston<- comorbidity(icd9, id= "patient_id", code = "code", map = "charlson_icd9_quan", assign0 = TRUE)

#combine 9 and 10
joint_charlston<- rbind(icd10_charleston,icd9_charleston)
joint_charlston_agg<- aggregate(.~patient_id, data =joint_charlston , FUN= max)
all_patients<- all_patients[,c("patient_id","year_of_index")]

joint_charlston_agg_age<- merge(all_patients, joint_charlston_agg, by=c("patient_id"))
#mi-myocardial infaction
#chf- congestive heart failure
#pvd- peripheral vascular disease
#cevd- cerebral vascular disease
#dementia-dementia
#cpd- chronic pulmonary disease
#rheumd- rheumatologic disease
#pud-peptic ulcer disease
#mld- mild liver disease
#diab-diabetes without complications
#diabwc-diabetes with complications 
#hp-hemipledgia adn paraplegia
#rend- renal disease
#canc- any malignancy
#msld-moderate or severe liver disease
#metacanc- metastatic solid tumor
#aids- aids

joint_charlston_agg_age$year_of_index
joint_charlston_agg_age$a50_59<- ifelse(joint_charlston_agg_age$year_of_index>=50 & joint_charlston_agg_age$year_of_index<=59,1,0)
joint_charlston_agg_age$a60_69<- ifelse(joint_charlston_agg_age$year_of_index>=60 & joint_charlston_agg_age$year_of_index<=69,2,0)
joint_charlston_agg_age$a70_79<-  ifelse(joint_charlston_agg_age$year_of_index>=70 & joint_charlston_agg_age$year_of_index<=79,3,0)
joint_charlston_agg_age$a80<-  ifelse(joint_charlston_agg_age$year_of_index>=80,4,0)
joint_charlston_agg_age$liver_adjusted<- ifelse(joint_charlston_agg_age$msld== 1,3,ifelse(joint_charlston_agg_age$mld==1,1,0))
joint_charlston_agg_age$diabetes_adjusted<- ifelse(joint_charlston_agg_age$diabwc== 1,2,ifelse(joint_charlston_agg_age$diab==1,1,0))
joint_charlston_agg_age$hp_adjusted<- ifelse(joint_charlston_agg_age$hp==1,2,0)
joint_charlston_agg_age$rend_adjusted<- ifelse(joint_charlston_agg_age$rend== 1,2,0)
joint_charlston_agg_age$cancer_adjusted<- ifelse(joint_charlston_agg_age$metacanc== 1,6,2)
joint_charlston_agg_age$aids_adjusted<- ifelse(joint_charlston_agg_age$aids==1,6,0)
joint_charlston_agg_age<- joint_charlston_agg_age[,c(1,3:10,20:29)]
joint_charlston_agg_age$score<- rowSums(joint_charlston_agg_age[,2:19])
write.csv(joint_charlston_agg_age,"~/Desktop/trinetx/charleston_scores.csv")


