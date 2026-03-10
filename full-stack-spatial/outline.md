
objective: 45 minutes of material and demos.

---

## Outline

- what is the R-ArcGIS Bridge
- the ecosystem of packages
- llms.txt files for AI coding assistance
- this workshop focuses on 5 packages:
  - arcgisutils: auth, portal search, misc utils
  - arcgislayers: reading and writing feature service data
  - arcgisgeocode: fast geocoding
  - calcite: Esri design system for Shiny
  - mapgl: interactive maps in Shiny
- arcgisutils: auth (synchronous / script context)
  - API key
  - username & password
  - client credentials
  - note: these are shared credentials, single token for the whole process
- arcgislayers: reading data
  - `arc_open()` + `arc_select()`
  - searching portal with `arc_search()`
- arcgisgeocode: geocoding
  - `suggest_places()` for autocomplete
  - `geocode_addresses()` for bulk
- what is Shiny
  - client/server architecture
  - websockets, input IDs, reactivity
- calcite design system
  - quick look at Esri developer site and components
  - page layouts: `page_sidebar()`, `page_actionbar()`
  - `open_example()` gallery
  - inputs, actions, feedback components
- maps in Shiny with mapgl
  - `maplibre()` + `esri_style()`
  - proxy updates, click events back to server
- auth in Shiny: `auth_shiny()`
  - unlike script auth, this is per-session
  - each user's connection is represented by a `session` object
  - `auth_shiny()` uses `session` to scope credentials per user
  - the right choice when users need to log in themselves
- demo app: geocode search + map explorer
  - address autocomplete in sidebar using `suggest_places()`
  - geocoded point added to map
  - click point to pull feature data via `arc_select()`
  - show results in a calcite table


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
