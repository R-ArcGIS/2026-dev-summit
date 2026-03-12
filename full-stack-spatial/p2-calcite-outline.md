# Part 2: Full Stack Spatial — Shiny, Calcite, and mapgl (~30 min)

---

## 1. Bridging to Part 2 (2 min)

**Slide — "The Backend is Done"** (3 bullets)
- arcgislayers, arcgisutils, arcgisgeocode = backend: data access, munging, analysis
- Lives in your R console — users never see it
- Natural next step: make it shareable

**Slide — "How do we share it?"** (3 bullets)
- Reports? Slides?
- Or... interactive applications
- Enter: Shiny

---

## 2. Conceptually: What is Shiny (6 min)

**Slide — title + the full-stack diagram image**
- Talk through it: browser on the right, R-ArcGIS packages on the left, Shiny in the middle

**Slide — "Two sides to every web app"** (2 bullets)
- Client = the browser (HTML, CSS, JS) — has no idea R exists
- Server = where R runs: your data, models, ArcGIS calls

**Slide — "How do they talk?"** (2 bullets)
- Persistent connection — messages flow both directions
- Browser: "slider moved to 42" → R reacts → sends back a new plot

**Slide — "You don't write any of that"** (1 bullet + code)
- Shiny handles the connection, the HTML, the JS — you just write R

```r
ui <- page_sidebar()

server <- function(input, output) {
  # input = messages from the browser
  # output = what you send back
}

shinyApp(ui, server)
```

**Slide — "Anatomy: input and output"** (2 bullets)
- `input$id` — read what the user did
- `output$id` — send something back to the browser

---

## 3. What is Calcite (3 min)

**Slide — title + side-by-side screenshot (ArcGIS Online / Field Maps vs a base Shiny app)**
- Native Shiny looks like 2012 — not Esri

**Slide — "Calcite Design System"** (3 bullets)
- Esri's design system — ArcGIS Online, Field Maps, Map Viewer are all built with it
- `{calcite}` brings it into Shiny
- Your app looks like it belongs in the ecosystem

**Slide — "Layout components" — diagram showing Shell → Shell Panel → Panel → Block hierarchy**
- Think of it as nested containers, each with a specific responsibility:
- `page_sidebar()` = the application frame — the overall structure (wraps Shell + Shell Panel)
- `calcite_panel()` = a content region — groups related content, lives inside the sidebar or main area
- `calcite_block()` = a collapsible section inside a panel — organize controls into labeled groups
- You build outward in: `page_sidebar()` → `calcite_panel()` → `calcite_block()` → your inputs

---

## 4. Building Intuition — Simple Examples (10 min)

**Framing before we start** — examples 1, 2, 3 are pure layout, no interaction yet. We're building the skeleton first so that when we add inputs it's clear where they live and why.

---

### `1-shiny-anatomy.R`

**Slide — code only**

- `page_sidebar()` — a layout function from `{calcite}` that creates a two-column shell: sidebar on the left, main content on the right
- `shinyApp(ui, server)` — the function that actually launches the app; takes the ui and server and wires them together
- Run it — it's blank, but the structure is there
- Everything we build from here goes inside this shell
- **Next objective**: populate the sidebar and main area with named regions

---

### `2-calcite-panel.R`

**Slide — code only**

- `calcite_panel()` — a content container; gives a region a heading and visual boundary
- We put one in the `sidebar` argument and one in the main content area
- The `sidebar` argument is what gets docked to the left — everything else goes to the right
- Run it — now the app has two clearly labeled regions
- **Next objective**: add collapsible sections inside the panels to organize controls

---

### `3-calcite-block.R`

**Slide — code only**

- `calcite_block()` — lives inside a `calcite_panel()`; creates a labeled, collapsible section
- `heading` names the section; `expanded = TRUE` means it starts open
- This is the full layout skeleton: `page_sidebar()` → `calcite_panel()` → `calcite_block()`
- Run it — panels have collapsible sections, still no inputs
- **Next objective**: put an actual input inside a block and connect it to the server

---

**Slide — "The Pattern"** (2 bullets)
- Give every input component an `id` in the UI
- Read it in the server via `input$id`

---

### `4-slider-ui.R` — UI only

**Slide — code only**

- `calcite_slider()` — a draggable range input; takes `id`, `min`, `max`, `value`, `label_text`
- `id` is how the server will identify this input — it must be unique
- The server is intentionally empty — we're focusing on what the UI looks like first
- Run it — the slider renders, looks polished, but dragging it does nothing yet
- **Next objective**: connect the slider to the server and see what value it sends

---

### `5-slider-server.R` — connecting to the server

**Slide — code + annotated printed output**

- `verbatimTextOutput("out")` — a UI placeholder that will render raw R output; the `"out"` id matches `output$out` in the server
- `renderPrint({ })` — a render function that evaluates its expression and sends the result back to `verbatimTextOutput`; re-runs automatically whenever its inputs change
- `output$out <- renderPrint({ input$my_slider })` — this closes the loop: slider moves → `input$my_slider` changes → `renderPrint` re-runs → output updates in the browser
- Drag the slider — watch the printed list update live

```r
# input$my_slider        => list(value = 50, ...)
# input$my_slider$value  => 50
```
- **Key gotcha**: calcite inputs return **lists**, not plain scalars like base Shiny inputs
- Use `$value` to extract the number — we'll use this pattern in every example from here
- **Next objective**: use `$value` to actually do something useful — drive a real output

---

### `5a-slider-histogram.R` — first real output

**Slide — live demo**

- Same pattern as before but now `input$bins$value` drives `renderPlot()` instead of `renderPrint()`
- `renderPlot({ })` — a render function that evaluates its expression and sends a plot back to `plotOutput()` in the UI
- `plotOutput("hist")` — the UI placeholder that receives the rendered plot
- `hist(faithful$waiting, breaks = input$bins$value)` — `input$bins$value` is just a number; plug it in anywhere you'd use a number in R
- The `verbatimTextOutput` is still there alongside the plot so you can see the raw list updating as you drag
- This is the reactive loop fully closed: UI input → server reacts → UI output updates
- **Next objective**: see how other input types follow the exact same pattern

---

### `6-button.R`

**Slide — code + live demo**

- `calcite_button()` — a clickable button; takes `id`, label text, `appearance`, `kind`
- `input$btn` is a list just like the slider — but the key property is `$clicks`, not `$value`
- `$clicks` is an integer that increments by 1 each time the button is pressed
- Click it — watch the count go up in the verbatim output
- The typical use is `observeEvent(input$btn$clicks, { ... })` to trigger a side effect when clicked — we'll use that pattern in the capstone
- **Next objective**: see the same list pattern with a select input, which adds a useful extra property

---

### `7-select.R`

**Slide — code + annotated output**

- `calcite_select()` — a dropdown; takes `id`, `label`, `values` (the underlying R values), `labels` (what the user sees)
- `values` and `labels` can differ — e.g. values are column names, labels are human-readable
- `input$pick` is again a list — two useful properties:

```r
# input$pick$value                  => "bill_length_mm"
# input$pick$selectedOption$label   => "Bill Length"
```

- `$value` = what you use in R code; `$selectedOption$label` = what you'd use in a plot axis title or UI label
- **Next objective**: now that we understand inputs, let's use them to filter a real dataset on a real map

---

## 5. Reactivity with observeEvent() (2 min)

**Slide — "Reacting to inputs"** (3 bullets)
- So far outputs re-render entirely when an input changes — fine for plots, bad for maps
- Re-rendering a map on every slider move is slow and jarring for the user
- `observeEvent()` lets you run arbitrary code when a specific input changes — without re-rendering

**Slide — code**
```r
observeEvent(input$min_pop, {
  # this runs every time the slider changes
  # do something targeted, not a full re-render
})
```
- First argument is what to watch, second is what to do
- Unlike `renderXxx()`, this doesn't produce an output — it just triggers a side effect
- Inputs can be NULL on startup before the user has interacted — use `req(input$id$value)` to bail out early if the value isn't ready yet

**Slide — "maplibre_proxy() + set_filter()"** (3 bullets)
- `maplibre_proxy("map")` gives you a handle to the already-rendered map
- `set_filter("layer_id", expression)` updates which features are visible — no re-render
- Filter expressions use MapLibre syntax: `list(">=", get_column("POPULATION"), 100000)`

**Slide — code**
```r
observeEvent(input$min_pop, {
  maplibre_proxy("map") |>
    set_filter(
      "cities",
      list(">=", get_column("POPULATION"), input$min_pop$value)
    )
})
```
- Map renders once with all data; proxy just toggles visibility on the client
- Fast, smooth — no round trip back to R for the data

---

## 6. Maps with mapgl (5 min)

**Slide — "What is mapgl?"** (4 bullets)
- R package by Kyle Walker
- Provides access to MapLibre — fast, modern, open-source map rendering
- Works in R, Quarto, and Shiny
- Supports Esri basemaps via `esri_style()` — powered by arcgisutils for auth

**Slide — "Key functions"** (4 bullets)
- `maplibre()` — create a map, takes a `style` argument
- `esri_style()` — returns an ArcGIS basemap style URL; requires `auth_user()` for the token
- `add_circle_layer()` — render point data on the map
- `maplibreOutput()` / `renderMaplibre()` — drop the map into Shiny just like `plotOutput()`

**Slide — "Auth note"** (2 bullets)
- `esri_style()` needs a token — pass `token = auth_user()`
- Same arcgisutils auth you already know from part 1

**Slide — `8-mapgl.R` code**
```r
calcite_panel(
  heading = "Map",
  style = "height: 100%",
  maplibreOutput("map", height = "100%")
)
```
- Skip `calcite_block()` here — put `maplibreOutput()` directly in the panel
- `style = "height: 100%"` on the panel + `height = "100%"` on the output = full height map

---

## 7. Capstone — USA Major Cities (8 min)

**Slide — "Putting it all together"** (3 bullets)
- Real data from a Feature Server via `arc_read()`
- Calcite layout with two inputs — slider and select
- `observeEvent()` + `maplibre_proxy()` + `set_filter()` for fast, smooth filtering

### `9-map-points.R` (2 min)

**Slide — code + screenshot**
- Read cities with `arc_read()`, render on map with `add_circle_layer()`
- `bounds = cities` zooms to the data automatically
- No server logic yet — just data on a map

### `10-map-filter-slider.R` (3 min)

**Slide — code + screenshot**
- Add population slider in the sidebar
- `observeEvent()` fires on slider change, `maplibre_proxy()` + `set_filter()` filters the layer
- Map never re-renders — only the filter updates

### `11-map-filter-select.R` (3 min)

**Slide — code + screenshot**
- Add state select — values derived from `sort(unique(cities$STATE_ABBR))`
- Filter expression combines both population AND state: `list("all", ..., ...)`
- `req(input$state$value)` guards against NULL on startup
- Full app: Calcite UI + ArcGIS data + ArcGIS basemap — the diagram from slide 1, fully built

**Slide — the full-stack diagram again**
- Close the loop: front end, back end, connected via Shiny
