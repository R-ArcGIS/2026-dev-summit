# R-ArcGIS Bridge Plenary



## Script


- Thanks, Simon!
- Today I’m going to show two new capabilities that bring the ArcGIS system and R closer together
- the latest release of the R-ArcGIS bridge introduces web tool support and access to the calcite design system
- While we R users are a mathy bunch, we also love building data-driven applications using a framework called shiny.
- I’ve built a custom web app in R to streamline incident reporting
- This app uses the web tool that Simon shared to validate new incidents that I want to upload
- I’ve got a file of new incidents to upload.
- before i can upload anything, the data needs to be validated.
- rather than reinventing the validation logic in the client app, the new web tool support means the app can call Simon’s web tool directly
- our app captured and reported the message from the service
- after passing validation, we can successfully run the tool, appending these new incidents to the web layer.
-	support for webtools in R also means we can also tap into ready to use ArcGIS analysis services like trace downstream, as well as dozens of other powerful hosted analysis services. 
-	I’ll select a handful of incidents and press run trace downstream
-	We’re now calling the Trace Downstream Hydrology service and waiting for the results to flow right back into our app
- with the R-ArcGIS bridge you now have more ways than ever to create integrated spatial analysis workflows and applications—by seamlessly connecting to web tools and leveraging calcite components to build apps that look and feel like part of the ArcGIS system,
