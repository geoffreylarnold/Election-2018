require(rgdal)
require(readxl)
require(dplyr)
require(leaflet)
require(htmltools)

pittwards <- readOGR("https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/VotingDistricts2017_May_v6/FeatureServer/0/query?where=Muni_War_1+LIKE+%27Pittsburgh%25%27&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=true&returnCentroid=false&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=standard&f=pgeojson&token=") %>%
  spTransform(CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

toc <- read_excel("detail.xlsx", sheet = "Table of Contents")

turnout <- read_excel("detail.xlsx", sheet = "Registered Voters") %>%
  mutate(`Voter Turnout` = as.numeric(gsub("%| ", "", `Voter Turnout`)))

senResults <- read_excel("detail.xlsx", sheet = "2")

govResults <- read_excel("detail.xlsx", sheet = "3") %>%
  rename(County = 1,
         `Wolf Total` = 5,
         `Wagner Total` = 8,
         Total = 18) %>%
  mutate(demGov = as.numeric(`Wolf Total`) / as.numeric(Total) * 100,
         repGov = as.numeric(`Wagner Total`) / as.numeric(Total) * 100) %>%
  select(c(County, demGov, repGov))

pittwards@data <- merge(pittwards@data, turnout, by.x = "Muni_War_1", by.y = "County", sort = FALSE, all.x = TRUE)
pittwards@data <- merge(pittwards@data, govResults, by.x = "Muni_War_1", by.y = "County", sort = FALSE, all.x = TRUE)

palTO <- colorNumeric("Greens", pittwards$`Voter Turnout`)

leaflet(data = pittwards) %>%
  addTiles() %>%
  addPolygons(color = ~palTO(`Voter Turnout`), 
              popup = ~paste0("<b>", Muni_War_1, "</b>: ",`Voter Turnout`, "%"),
              fillColor = ~palTO(`Voter Turnout`),
              fillOpacity = .8) %>%
  addLegend(position = "bottomright", pal = palTO, values = ~`Voter Turnout`, title = "Voter Turnout (%)")

bins <- seq(from = 0, to = 100, length.out = 11)
palDem <- colorBin("RdBu", domain = 0:100, bins = bins, pretty = F)

leaflet(data = pittwards) %>%
  addTiles() %>%
  addPolygons(color = ~palDem(demGov), 
              popup = ~paste0("<b>", Muni_War_1, "</b>: <br>Wolf: ", round(demGov, 2), "%",
                              "<br>Wagner: ", round(repGov,2), "%"),
              fillColor = ~palDem(demGov),
              fillOpacity = 0.8)

allWards <- readOGR("https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/VotingDistricts2017_May_v6/FeatureServer/0/query?where=1=1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=true&returnCentroid=false&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=standard&f=pgeojson&token=") %>%
  spTransform(CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

allWards@data <- merge(allWards@data, turnout, by.x = "Muni_War_1", by.y = "County", sort = FALSE, all.x = TRUE)
allWards@data <- merge(allWards@data, govResults, by.x = "Muni_War_1", by.y = "County", sort = FALSE, all.x = TRUE)

palTO <- colorNumeric("Greens", allWards$`Voter Turnout`)

leaflet(data = allWards) %>%
  addTiles() %>%
  addPolygons(color = ~palTO(`Voter Turnout`), 
              popup = ~paste0("<b>", Muni_War_1, "</b>: ",`Voter Turnout`, "%"),
              fillColor = ~palTO(`Voter Turnout`),
              fillOpacity = .8) %>%
  addLegend(position = "bottomright", pal = palTO, values = ~`Voter Turnout`, title = "Voter Turnout (%)")

leaflet(data = allWards) %>%
  addTiles() %>%
  addPolygons(color = ~palDem(demGov), 
              popup = ~paste0("<b>", Muni_War_1, "</b>: <br>Wolf: ", round(demGov, 2), "%",
                              "<br>Wagner: ", round(repGov,2), "%"),
              fillColor = ~palDem(demGov),
              fillOpacity = 0.8,
              opacity = .95) %>%
  addLegend(pal = palDem, values = bins, title = "Wolf Vote Share")
