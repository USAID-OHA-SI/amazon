#install.packages(c("remotes", "devtools", "tidyverse"))
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

existing_pkgs %>% 
  filter(!package %in% local_pkgs$Package) 
  
# remotes::install_github("USAID-OHA-SI/glamr", build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/glitr", build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/grabr", build_vignettes = TRUE)
# remotes::install_github("USAID-OHA-SI/gisr")
# remotes::install_github("USAID-OHA-SI/gophr")
# remotes::install_github("USAID-OHA-SI/Wavelength")
# remotes::install_github("USAID-OHA-SI/tameDP")
# remotes::install_github("USAID-OHA-SI/COVIDutilities")
# remotes::install_github("USAID-OHA-SI/selfdestructin5")
# remotes::install_github("USAID-OHA-SI/cascade")

# Install Pacakges from file
# NOTE - You may need to do multiple runs to get all of them installed.

existing_pkgs %>% 
  filter(!package %in% local_pkgs$Package,
         str_detect(repository, "USAID-OHA-SI", negate = TRUE)) %>% 
  select(package, repository) %>% 
  pwalk(function(package, repository) {
    
    print(paste0(package, ": ", repository))
    
    curr_pkgs <- installed.packages() %>% as_tibble()
    
    gh <- "https://github.com/"
    cr <- "https://cran.rstudio.com"
    
    repo <- repository %>% 
      str_split(",") %>% 
      unlist() %>% 
      first() %>% 
      str_trim(side = "both")
    
    if(!package %in% curr_pkgs$Package) {
      
      print("Package is being installed ...")
    
      if (str_detect(repo, gh)) {
        
        name <- str_remove(repo, gh)
        
        remotes::install_github(repo = name)
      }
      else if (str_detect(repo, cr)) {
        install.packages(package, dependencies = TRUE)
      } 
      else {
        print(paste0("WARN - Not sure how to install this: ", repo))
      }
    } 
    else {
      print("Package already installed.")
    }
    
  })


