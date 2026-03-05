# Full-Stack Spatial with R and ArcGIS


## Outline: 

- what is the R-ArcGIS Bridge
- the ecosystem
- llms.txt files for AI coding assistance
- this workshop will be focused on building apps using 5 pkgs:
  - arcgisutils - for auth, portal, misc other utils 
  - arcgislayers - reading data
  - calcite - 
  - shiny
  - mapgl
- approaches to authentication

## App ideas?

- Side bar with search that uses arcgisgeocode for suggest
  - new points get added to the map
  - use mapgl to get point id
  - add pop-up table for the selected point?
- Geocoding tables from the app?
  - login as a user
  - list tables from portal
  - read table
  - geocode
  - have download address csv
- 


-----

## Misc notes: 

Two parts to most web applications and shiny is no different. 
There is the server and the client. 
Client is the web browser
Server is what is actually doing the computation 
The client runs client specific application code. This is where all of the stuff that defines the ui is. 
HTML css and JavaScript 
The sever is where the R code actually runs. 
How do these communicate? They use something called websockets. The client code sends information through this connection. The server is actively listening. These messages get captured and processed by R 
R also can send information back through these websockets.
Events and updates
Using inputs in the server functions. So how do we connect the server to the client? Ui? We give the ui elements unique IDs
Creating layouts using page functions.
