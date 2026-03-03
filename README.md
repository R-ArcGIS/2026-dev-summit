# R-ArcGIS Bridge Plenary

Duration: 1 minute 45 seconds

Audience: Esri's 2026 Developer Summit. In the crowd are mostly IT admins, web developers, data scientists, and other people that program in various langauges like Java, JavaScript, Kotlin, Swift, Python, Rust, etc. We cannot assume that everyone knows what R is or what the R-ArcGIS Bridge is. We need to be subtle, clear, and quick when we discuss these things.


## Preceding Demo

Web tools allow anyone to run geoprocessing workflows | built in Python or ModelBuilder as a service | across Pro, Enterprise, and the web.

But when users bring inconsistent data, tools can fail. 

I’ll show how you can publish a custom web tool with validation to catch issues before the tool runs
This Python toolbox is used by analysts in our organization to upload oil spill data to an enterprise geodatabase after checking it for expected schema and data quality. 
This tool’s validation raises an error when the extent is outside of the Washington State boundary.
The Python toolbox works great in Pro, now I want to run the same workflow from a web app. So I am publishing it as a web tool. 
In Pro 3.7 you can publish directly from the toolbox, no need to run it first. I will select the whole Python toolbox to publish.
In the Sharing pane, under Configurations,I enable the Validate capability And publish
While that publishes, here are some new features that were just created by an analyst that need to be uploaded.
let’s test the web tool here in Pro before sharing it with others. Web tools appear in the Catalog Portal tab.
I’ll choose the input features to upload and click validate. The custom error tells me that I’m uploading too many features. This quick check was run on the server using the custom Python code authored for the Pro tool and published to my server. 
Let me fix the input and choose the extent of the city.  Click Validate again, everything checks out and I’m ready to upload this dataset.
Validation catches issues early improving the web tool user experience, protects your server, and helps ensure reliable results.
Next, Josiah will now demonstrate using this same web tool and the validation service from Ra web application built with R.


## R-ArcGIS Bridge Demo

- This 90 second demo is intended so showcase two new key functionalities for the R-ArcGIS Bridge
- First is Geoprocessing Service support 
- Second is the {calcite} R package which lets you use the Esri Calcite Design System within the Shiny application framework for R

One key point i want to find a way to stress is that geoprocessing services are a language agnostic way to share custom functionality with other developers regardless of language. I just so happen to love R first and foremost. 
The validation endpoints provide me with a way to harness the error messages.

I will build an R shiny app. I will use the `arc_gp_job()`—maybe i'll even have a

I want to also say something like data scientists love R. but R users also love creating data driven interactive applications using the shiny framework.
We have begun building out hand-crafted shiny bindings to the Calcite Design system. Using this you can create apps that fit in the Esri system using the R-ArcGIS Bridge to somethin something.

- The web tool that simon just published from ArcGIS Pro is now available as a geoprocessing service.
- GP services are a language-agnostic way to deploy a distribute bespoke functionality to developers of _any_ language
- I am an avid R user and developer of our R-ArcGIS Bridge project
- With the most recent release of our open source packages, we can interact with those geoprocessing services natively from R!
- While we R users are a mathy bunch, we also **love** building data-driving applications using the Shiny framework. 
- We've built out bindings to the Esri Calcite Design system so that you too can create apps that feel native to the Esri Ecosystem.
- We can leverage the R-ArcGIS Bridge to built out a tailored application UI that harnesses Simon's GP service on the server-side
- This validate button calls out directly to the service


-----

## Script


0:00–0:20

- *Positron open with a short standalone R script, ~6 lines. Run it. Console shows the result.*
- Thanks Simon!
- Many data scientists and researchers leverage R in their work.
- Today I'm going to show two new capabilities that bring the ArcGIS system and R closer together 
- the latest release of the R-ArcGIS bridge introduces web tool support
  - and bindings to the calcite design system
- {need transition}
- *run reading of points*
- i'm going to validate new incidents against Simon's service
- *run the validate line*
- using the webtool support

0:20–0:35

- *show shiny app R script*
- While we R users are a mathy bunch, we also love building data-driven applications using the shiny framework.
  - ^ highlight `library(shiny)`
- the calcite package makes our apps look and feel like part of the ArcGIS system
- *Switch to Shiny app running in browser. Map visible, incidents plotted, Calcite sidebar on left. Address bar hidden.*
- I've built a custom web app in R to aid in incident reporting

0:35–1:10

- *Upload panel active. Upload a CSV with features outside the expected spatial extent.*
- I've got some new spill incidents to upload.
- *Load the CSV. Columns auto-populate. Summary appears.*
- before i can upload anything, we need to validate our dataset 
- *Click Validate.*
- rather than reinventing the validation logic in our app, this is calling simon's web tool directly
- *Warning alert fires—wrong spatial extent.*
- our app captured and reported the message from the service
- *Swap to correct CSV.*
- now we will upload the correct data
- and ensure it falls within the the expected extent
- *points are validated successfully*
- after passing validation, we can successully run our tool


1:10 - 2:00

- *Click Upload Features. Scrim briefly. Points merge into map.*
- support for webtools means we can also tap into ready to use analysis services
- *Switch to Analysis panel.*
- *Draw a polygon around the newly uploaded points.*
- I'll select a handful of incidents I just added and run trace downstream
- *Click Run Trace Downstream. Brief loading.*
- We're now calling the Trace Downstream Hydrology service and waiting for the results to flow right back into our app
- *Trace result on screen.*
- With the R-ArcGIS Bridge, we can now call geoprocessing services natively from R.
- And with our new  Calcite design integration, we can build applications that fit right into the ArcGIS ecosystem.

---

## Pre-demo setup checklist

- [ ] Positron open with short standalone R script (not `app.R`)
- [ ] Shiny app already running in browser, address bar hidden
- [ ] Map centered on data extent, incidents visible and styled
- [ ] Two CSVs ready: one that fails (wrong spatial extent), one that passes (correct location, small)
- [ ] Know exactly which uploaded point to draw around for the trace
- [ ] Coordinate symbology color with Simon beforehand
