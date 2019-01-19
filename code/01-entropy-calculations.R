library(landscapemetrics)
library(tmap)
library(raster)

data("augusta_nlcd")
augusta_nlcd = deratify(augusta_nlcd, "NLCD.2011.Land.Cover.Class")
writeRaster(augusta_nlcd, "augusta_nlcd.tif")

nlcd_colors = c("#00F900", "#476BA0", "#D1DDF9", "#DDC9C9", "#D89382", "#ED0000", 
                "#AA0000", "#B2ADA3", "#F9F9F9", "#68AA63", "#1C6330", "#B5C98E", 
                "#A58C30", "#CCBA7C", "#E2E2C1", "#C9C977", "#99C147", "#77AD93", 
                "#DBD83C", "#AA7028", "#BAD8EA", "#B5D3E5", "#B5D3E5", "#B5D3E5", 
                "#B5D3E5", "#70A3BA")

tm_shape(augusta_nlcd) +
  tm_raster("NLCD.2011.Land.Cover.Class", palette = nlcd_colors) + 
  tm_layout(legend.outside = TRUE)

system("gpat_gridhis -i augusta_nlcd.tif -o augusta_ent.grd -s 'ent' -n 'none' -z 20 -f 20")
system("gpat_grid2txt -i augusta_ent.grd -o augusta_ent.txt")

library(rgeopat2)
library(sf)
augusta_ent = gpat_read_txt("augusta_ent.txt", signature = "ent")

head(augusta_ent)


augusta_grid = gpat_create_grid("augusta_ent.grd.hdr")

p2 = tm_shape(augusta_nlcd) +
  tm_raster("NLCD.2011.Land.Cover.Class") + 
  tm_shape(augusta_grid) +
  tm_borders() + 
  tm_layout(legend.outside = TRUE)
p2

library(dplyr)

augusta_grid = bind_cols(augusta_grid, augusta_ent)

p3 = tm_shape(augusta_nlcd) +
  tm_raster(legend.show = FALSE) +
  tm_shape(augusta_grid) +
  tm_polygons("Shannon_entropy") + 
  tm_layout(legend.outside = TRUE)

tmap_arrange(p2, p3)
