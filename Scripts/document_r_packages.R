library(tidyverse)

local_pkgs <- installed.packages() %>% 
  as_tibble() %>%
  pull(Package)

cran_pkgs <- available.packages() %>% 
  as_tibble() %>% 
  select(Package, Version, Imports, Suggests, Repository) %>% 
  filter(Package %in% local_pkgs)

gh_pkgs <- setdiff(local_pkgs, cran_pkgs$Package)

local_gh_pkgs <- installed.packages() %>% 
  as_tibble() %>% 
  select(Package, Version, Imports, Suggests) %>% 
  filter(Package %in% gh_pkgs) 

my_pkgs <- cran_pkgs %>% 
  bind_rows(local_gh_pkgs) %>% 
  mutate(Description = map_chr(Package, ~ utils::packageDescription(.x)$Description))


write_csv("Dataout/OHA_R_packages.csv", na = "")