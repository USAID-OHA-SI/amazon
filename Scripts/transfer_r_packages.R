# .libPaths

# Previous lib path
prev_lib <- lib_loc <- paste0("C:/Users/", 
                              Sys.getenv("USERNAME"), 
                              "/Documents/R/win-library/4.1")

# New lib path
curr_lib <- lib_loc <- paste0("C:/Users/", 
                              Sys.getenv("USERNAME"), 
                              "/Documents/R/win-library/4.2")

if (!dir.exists(curr_lib)) dir.create(curr_lib)

.libPaths(new = curr_lib)
.libPaths()

# Install start up packages into new lib paths
#install.packages(c("remotes", "tidyverse"), lib =  curr_lib)

# Load start up libraries
library(remotes, lib.loc = curr_lib)
library(tidyverse, lib.loc = curr_lib)

# Github Package
gh <- "https://github.com/"

# 
local_pkgs <- installed.packages(lib.loc = prev_lib) %>% 
  as_tibble() 

cran_pkgs <- available.packages() %>% 
  as_tibble() %>% 
  select(Package, Version, Imports, Suggests, Repository) %>% 
  filter(Package %in% local_pkgs$Package)

gh_pkgs <- setdiff(local_pkgs$Package, cran_pkgs$Package)

local_gh_pkgs <- local_pkgs %>%  
  select(Package, Version, Imports, Suggests) %>% 
  filter(Package %in% gh_pkgs) %>% 
  mutate(Repository = map(
    Package, possibly(~ packageDescription(.x, lib.loc = prev_lib)$URL, 
                                            otherwise = " "))) %>% 
  unnest(Repository)

my_pkgs <- cran_pkgs %>% 
  bind_rows(local_gh_pkgs) %>% 
  rename_all(tolower)

# remotes::install_github("USAID-OHA-SI/glamr", lib = curr_lib, build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/glitr", lib = curr_lib, build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/gisr", lib = curr_lib, build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/gophr", lib = curr_lib, build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/Wavelength", lib = curr_lib, build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/tameDP", lib = curr_lib, build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/COVIDutilities", lib = curr_lib, build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/selfdestructin5", lib = curr_lib, build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/gagglr", lib = curr_lib, build_vignettes = TRUE)


my_pkgs %>% 
  select(package, repository) %>% 
  filter(str_detect(repository, gh, negate = T)) %>% # 
  #filter(str_detect(repository, gh)) %>% 
  pwalk(function(package, repository) {
    
    print(package)
    
    curr_pkgs <- installed.packages(lib.loc = curr_lib) %>% 
      as_tibble() %>% 
      rename_all(tolower)
    
    if(!package %in% curr_pkgs$package) {
      
      print(paste0("Package [", package, "] is being installed ..."))
      print(repository)
      
      if (str_detect(repository, gh)) {
        
        repo <- str_remove(repository, gh)
        
        remotes::install_github(repo, lib = curr_lib)
      }
      else {
        install.packages(package, lib = curr_lib, dependencies = TRUE)
      }
    } 
    else {
      print("Package already installed.")
    }
    
  })


