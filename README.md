# R-ArcGIS Bridge Plenary


- Thanks, Simon!
- Today I’m going to show two new capabilities that bring the ArcGIS system and R closer together
- the latest release of the R-ArcGIS bridge introduces web tool support and access to the calcite design system
- While we R users are a mathy bunch, we also love building data-driven applications using a framework called shiny.
- I’ve built a custom web app in R to streamline incident reporting

- This app uses the web tool that Simon shared to validate new incidents 
- I’ve got a file of new incidents to upload.
- before i can upload anything, the data needs to be validated.
- rather than reinventing the validation logic in the client, 
  - the new web tool support means the app can call Simon’s service
- our app captured and reported the message directly

- Ill now upload CSV file which falls within the expected extent
- after passing validation, we can successfully run the tool, appending these new incidents to the web layer.


-	support for webtools in R  means we can also tap into dozens of ready to use ArcGIS analysis services
-	I’ll select a handful of incidents and press run trace downstream
-	We’re now calling the Trace Downstream Hydrology service and waiting for the results to flow right back into our app

- With the R-ArcGIS bridge, R connects directly into the ArcGIS system. 
- The same web tools your organization relies can now power your Shiny apps
- and with the Calcite integration, those apps look and feel like a natural part of the ArcGIS ecosystem
