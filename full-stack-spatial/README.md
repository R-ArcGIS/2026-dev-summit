# Full-Stack Spatial with R and ArcGIS

**Abstract**:

> Learn how to leverage the full breadth of the R-ArcGIS Bridge from feature service management, scalable geocoding, and building beautiful web applications with Shiny and the Calcite Design System. This technical session demonstrates reading data from your web-based services, authentication strategies, searching your portal, and scalable geocoding. The session culminates by integrating these into a Shiny web application that shows how spatial data scientists can seamlessly connect R's analytical capabilities with ArcGIS data and services to create comprehensive workflows leveraging the R ecosystem.

## Pre-requisites

This workshop will use the following R packages:

- arcgisutils
- arcgislayers
- arcgisgeocode
- calcite
- shiny
- mapgl

```r
install.packages(
  c("arcgisutils", "arcgislayers", "arcgisgeocode", "calcite", "mapgl")
)
```

## LLM contexts

We recognize that AI is part of the development experience these days. As such we have provided `llms.txt` files for some of our packages: 

- arcgisutils: https://r.esri.com/arcgisutils/llms.txt
- arcgislayers: https://r.esri.com/arcgislayers/llms.txt
- arcgisgeocode: https://r.esri.com/arcgisgeocode/llms.txt
- calcite: https://r.esri.com/calcite/llms.txt
- mapgl: https://walker-data.com/mapgl/llms.txt
