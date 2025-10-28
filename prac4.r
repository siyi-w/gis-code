library(sf)
world <- st_read("World_Countries.geojson")
library(readr)
gii <- read_csv("hdr-data.csv")
library(dplyr)
library(countrycode)
gii$iso3 <- countrycode(gii$CountryName, "country.name", "iso3c")
colnames(gii)
gii$iso3 <- countrycode(gii$country, "country.name", "iso3c", warn = FALSE)
library(dplyr)

gii_gii <- gii %>%
  filter(indexCode == "GII", year %in% 2010:2019, country != "World") %>%
  select(country, iso3, year, value)
gii_diff <- gii_gii %>%
  group_by(country, iso3) %>%
  reframe(
    gii_diff = value[year == 2019] - value[year == 2010]
  ) %>%
  filter(!is.na(gii_diff))
world <- world %>%
  left_join(gii_diff, by = c("ISO_A3" = "iso3"))
colnames(world)
world <- world %>%
  left_join(gii_diff, by = c("ISO" = "iso3"))
st_write(world, "world_gii_diff.geojson", delete_dsn = TRUE)

library(dplyr)

world_clean <- world %>%
  select(FID, COUNTRY, ISO, gii_diff, geometry)
st_write(world_clean, "world_gii_diff.geojson", delete_dsn = TRUE)

