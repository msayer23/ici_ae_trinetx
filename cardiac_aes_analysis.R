#cardio analysis
cardio_combined_ae<- read.csv("~/Desktop/trinetx/all_cardio_ae_ici_demo_061323.csv")
cardio_combined_ae<- cardio_combined_ae[,-c(1)]


cardio_combined_ae_trimmed<- cardio_combined_ae %>% select(patient_id,code,dx_date_jul,ici.1,sex,race,ethnicity,year_of_birth,nivolumab,pembrolizumab,
                                                           ipililumab,cemiplimab,atezolizumab,durvalumab,avelumab,dostarlimab)


#Myocarditis related
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i40.1"]<- "myocarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i40.9"]<- "myocarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i40.8"]<- "myocarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i51.4"]<- "myocarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "422.91"]<- "myocarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "422.93"]<- "myocarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "422.99"]<- "myocarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "422.90"]<- "myocarditis"

#Pericarditis related
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i30.8"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i30.9"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i30.0"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i31.2"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i31.3"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i31.4"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i31.8"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i31.9"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i32"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i31.39"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "i31.31"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "420.91"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "420.99"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "420.90"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "423.0"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "423.3"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "423.8"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "423.9"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "115.03"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "115.13"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "115.93"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "420.0"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "423.8"]<- "pericarditis"
cardio_combined_ae_trimmed[cardio_combined_ae_trimmed== "423.9"]<- "pericarditis"
cardio_combined_ae_trimmed$unique<- paste(cardio_combined_ae_trimmed$patient_id,cardio_combined_ae_trimmed$dx_date_jul,sep="")


#join
cardio_combined_ae_trimmed_agg<- aggregate(cardio_combined_ae_trimmed$dx_date_jul, by=list(cardio_combined_ae_trimmed$patient_id,cardio_combined_ae_trimmed$code), FUN= min)
colnames(cardio_combined_ae_trimmed_agg)<- c("patient_id","icd_code","first_icd_date")
cardio_combined_ae_trimmed_agg<- setDT(cardio_combined_ae_trimmed_agg)[,counter := seq_len(.N),by=.(patient_id)]
cardio_combined_ae_trimmed_agg$ae_type<- paste("ae",cardio_combined_ae_trimmed_agg$counter,sep="")
cardio_combined_ae_trimmed_agg<- cardio_combined_ae_trimmed_agg %>% select(-c("counter"))
cardio_combined_ae_trimmed_agg<- cardio_combined_ae_trimmed_agg %>% pivot_wider(values_from = icd_code,names_from = ae_type) %>% as.data.frame()
cardio_combined_ae_trimmed_agg<- cardio_combined_ae_trimmed_agg %>% rowwise() %>% 
  mutate(final_ae= paste(na.omit(c_across(starts_with("ae"))), collapse="&")) %>% as.data.frame()
cardio_combined_ae_trimmed_agg$unique<- paste(cardio_combined_ae_trimmed_agg$patient_id,cardio_combined_ae_trimmed_agg$first_icd_date,sep="")


cardio_combined_ae_trimmed_agg_2<- aggregate(cardio_combined_ae_trimmed_agg$first_icd_date,by=list(cardio_combined_ae_trimmed_agg$patient_id),FUN=min)
cardio_combined_ae_trimmed_agg_2$unique<- paste(cardio_combined_ae_trimmed_agg_2$Group.1,cardio_combined_ae_trimmed_agg_2$x,sep="")


#min ids pulled with exact event data, this delivers table with with first ae occuring and its time
cardio_combined_ae_trimmed_agg <- cardio_combined_ae_tr
cardio_combined_ae_trimmed_agg$firstone<- ifelse(cardio_combined_ae_trimmed_agg$unique %in% cardio_combined_ae_trimmed_agg_2$unique,1,0)
cardio_combined_ae_trimmed_agg<- cardio_combined_ae_trimmed_agg %>% filter(firstone== 1)
cardio_combined_ae_trimmed_agg<- cardio_combined_ae_trimmed_agg %>% select(patient_id,first_icd_date,final_ae)
ae_frequency_table<- cardio_combined_ae_trimmed_agg %>% count(final_ae)%>% group_by(final_ae) %>% arrange(desc(n))%>%as.data.frame()
colnames(ae_frequency_table)<- c("ae","count")

#cardio_combined_ae_trimmed_agg

#bringbackinfo
cardio_combined_ae_trimmed1<- cardio_combined_ae_trimmed[,c("patient_id","sex","race","ethnicity","ici.1","year_of_birth","nivolumab","pembrolizumab","ipililumab","cemiplimab","atezolizumab","durvalumab","avelumab","dostarlimab")]
cardio_combined_ae_trimmed1 <- cardio_combined_ae_trimmed1 %>% distinct(patient_id, .keep_all = TRUE)

combine_first_ae<- merge(cardio_combined_ae_trimmed_agg,cardio_combined_ae_trimmed1,all.x = TRUE,by="patient_id")
combine_first_ae$nivolumab_yn<- ifelse(combine_first_ae$nivolumab<= combine_first_ae$first_icd_date,"nivolumab",NA)
combine_first_ae$pembrolizumab_yn<- ifelse(combine_first_ae$pembrolizumab<= combine_first_ae$first_icd_date,"pembrolizumab",NA)
combine_first_ae$ipililumab_yn<- ifelse(combine_first_ae$ipililumab<= combine_first_ae$first_icd_date,"ipililumab",NA)
combine_first_ae$cemiplimab_yn<- ifelse(combine_first_ae$cemiplimab<= combine_first_ae$first_icd_date,"cemiplimab",NA)
combine_first_ae$atezolizumab_yn<- ifelse(combine_first_ae$atezolizumab<= combine_first_ae$first_icd_date,"atezolizumab",NA)
combine_first_ae$durvalumab_yn<- ifelse(combine_first_ae$durvalumab<= combine_first_ae$first_icd_date,"durvalumab",NA)
combine_first_ae$avelumab_yn<- ifelse(combine_first_ae$avelumab<= combine_first_ae$first_icd_date,"avelumab",NA)
combine_first_ae$dostarlimab_yn<- ifelse(combine_first_ae$dostarlimab<= combine_first_ae$first_icd_date,"dostarlimab",NA)

combine_first_ae$med_taken<- apply(combine_first_ae[,17:24],1,function(row) paste(na.omit(row), collapse = ","))
combine_first_ae$med_taken[combine_first_ae$med_taken==""]<- "missing"
combine_first_ae<- combine_first_ae[,c(1:16,25)]

#combine_first_ae, this table has demographic info, first ici.1 time, demographic info, meds taken prior to ici
write.csv(combine_first_ae,"~/Desktop/trinetx/firstici_firstae_dateoficis_061323.csv")
#ICIs taken at first ae
ici_taken_table<- combine_first_ae %>% count(med_taken)%>% group_by(med_taken) %>% arrange(desc(n))%>%as.data.frame()
colnames(ici_taken_table)<- c("medications_taken","count")
write.csv(ici_taken_table,"~/Desktop/trinetx/ici_taken_table_cardioaes.csv")

# of ae
table(combine_first_ae$final_ae)

#ICIs taken when experiencing and ae
sort(table(combine_first_ae$med_taken), decreasing = TRUE)

#combine_first_ae gender
table(combine_first_ae$sex)
table(combine_first_ae$sex,combine_first_ae$final_ae)

#race
table(combine_first_ae$race)
table(combine_first_ae$race,combine_first_ae$final_ae)

#ethnicity
table(combine_first_ae$ethnicity)
table(combine_first_ae$ethnicity,combine_first_ae$final_ae)

#time to first ae
combine_first_ae$ttfae<- combine_first_ae$first_icd_date-combine_first_ae$ici.1
summary(combine_first_ae$ttfae)

####Add some chemotherapy data


