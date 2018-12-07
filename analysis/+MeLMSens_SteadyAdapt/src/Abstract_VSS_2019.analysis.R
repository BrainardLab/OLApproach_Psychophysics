library(tidyverse)
library(knitr)
library(stringr)
library(glue)
options(digits = 3)
source('../lib/median_SEM.R')

csvsPath = normalizePath("../../data/processed")
csvfiles = list.files(csvsPath, recursive = TRUE, pattern = 'results_.*.csv')

results_all = lapply(csvfiles,function(x) {
  read_csv(file.path(csvsPath,x), col_types = cols())
}) %>%
  bind_rows

results_clean = results_all %>%
  separate(datafile,into=c("marker","participant","session","acquisition"),sep="-") %>%
  select(-marker, -acquisition) %>%
  
  # Select only relevant columns
  select(participant, session, axis, adaptationLevel, fitThresholdContrast, fitJND) %>%
  
  # Recode adaptationLevel as factor
  mutate(adaptationLevel= factor(adaptationLevel,levels=c('low','high'))) %>%
  
  # Rename participants
  mutate(participant = recode_factor(participant, HERO_GKA = "P1", HERO_DHB = "P2", HERO_JXV = "P3")) %>%
  
  # Rename sessions
  mutate(session = factor(str_replace(session,'session_',''),ordered=TRUE))

JNDs = results_clean %>%
  # Convert to wide-format: separate columns for high/low
  select(-fitThresholdContrast) %>%
  spread(key = adaptationLevel, value = fitJND)

JNDs = JNDs %>%
  # Normalize to median(low) -- median across sessions per participant per axis
  group_by(participant,axis) %>%
  mutate(high = high/median(low),
         low = low/median(low))

summaryJNDs = JNDs %>% 
  group_by(participant, axis) %>%
  summarise(p = t.test(high,low,paired=TRUE)$p.value,
            t = t.test(high,low,paired=TRUE)$statistic,
            low_sem = SEMedian(low),
            high_sem = SEMedian(high),
            low = median(low, na.rm=TRUE),
            high = median(high, na.rm=TRUE)) %>%
  arrange(axis, participant) %>%
  select(participant, axis, low, low_sem, high, high_sem, t, p)