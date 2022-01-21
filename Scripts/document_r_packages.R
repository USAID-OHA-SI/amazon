library(tidyverse)

local_pkgs <- installed.packages() %>% 
  as_tibble() 

cran_pkgs <- available.packages() %>% 
  as_tibble() %>% 
  select(Package, Version, Imports, Suggests, Repository) %>% 
  filter(Package %in% local_pkgs$Package)

gh_pkgs <- setdiff(local_pkgs$Package, cran_pkgs$Package)

local_gh_pkgs <- local_pkgs %>%  
  select(Package, Version, Imports, Suggests) %>% 
  filter(Package %in% gh_pkgs) %>% 
  mutate(Repository = map(Package, possibly(~ packageDescription(.x)$URL, 
                                                otherwise = " "))) %>% 
  unnest(Repository)

my_pkgs <- cran_pkgs %>% 
  bind_rows(local_gh_pkgs) %>% 
  arrange(Package) %>% 
  mutate(Description = map_chr(Package, ~ packageDescription(.x)$Description)) %>% 
  rename_all(tolower)

existing_pkgs <- read_csv("Dataout/OHA_R_packages.csv")

new_pkgs <- my_pkgs %>% 
  bind_rows(existing_pkgs %>% 
              filter(!package %in% my_pkgs$package)) %>% 
  arrange(package)

write_csv(new_pkgs,
          "Dataout/OHA_R_packages.csv", 
          na = "")
