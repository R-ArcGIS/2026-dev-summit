# R-ArcGIS Bridge Plenary

Duration: 90 seconds

Audience: Esri's 2026 Developer Summit. In the crowd are mostly IT admins, web developers, data scientists, and other people that program in various langauges like Java, JavaScript, Kotlin, Swift, Python, Rust, etc. We cannot assume that everyone knows what R is or what the R-ArcGIS Bridge is. We need to be subtle, clear, and quick when we discuss these things.


## Preceding Demo
This 90 second demo will immediately follow a 90 second presentation that demonstrates publishing web tools from ArcGIS pro to ArcGIS Enterprise.
They will demonstrate the new "Validate" feature and endpoint from the deployed webtool. This is a new endpoint which lets you use validate arguments before to the GP service before you use it. 


Drafted talk:
The below is taken from a drafted word doc from my colleague

- Web tools allow anyone to run geoprocessing workflows built in Python or ModelBuilder as a service across Pro, Enterprise, and the web. 
- But when users bring inconsistent data, tools can fail.  
- I’ll show how custom web tool validation catches issues before the tool runs, improving the tool user experience, decreasing server load, and bringing equivalency with custom Python tools in Pro. 
- This Python toolbox is used by analysts in our organization to upload data to an enterprise geodatabase after checking it for expected schema and data quality.  
Tool validation lets you customize tool behaviors including showing and hiding parameters, updating choice lists, changing default values, and raising custom error messages before run time. This tool’s validation raises an error when the number of features to upload is inappropriate.  

 

 

(Alternative checks 

Check if certain fields are present 

If fields has the correct type, like ID should be GPLong instead of String etc 

Geometry type  check) 

The Python toolbox works great in Pro, now I want to run the same workflow from a web app. So I am publishing it as a web tool.  
In Pro 3.7 you can publish directly from the toolbox, no need to run it first. I will select the whole Python toolbox to publish. 
In the Sharing pane, under Configurations,I enable the Validate capability And publish 
While that publishes, here are some new features that were just created by an analyst that need to be uploaded. 
let’s test the web tool here in Pro before sharing it with others. Web tools appear in the Catalog Portal tab. 
i’ll choose the input features to upload and click validate. The custom error tells me that I’m uploading too many features. This quick check was run on the server using the custom Python code authored for the Pro tool and published to my server. 
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

## Script outline

summary: show the GP service called in R code first, then switch to a Shiny app with Calcite UI wrapping the same call. The validate endpoint is the thread connecting both halves to Simon's demo.


I will be using Positron as my editor.

---

Time: 0:00-0:10
Visual: Simon's published service on screen
Script: Thank you, Simon. GP services are a language-agnostic way to deploy and distribute bespoke functionality to developers of any language.

Time: 0:10-0:25
Visual: Positron with a short R script, run it, result in the console
Script: I'm an avid R user and developer of the R-ArcGIS Bridge. With our newest release, we support geoprocessing services directly. We can leverage Simon's workflow without reinventing the wheel.

Time: 0:25-1:05
Visual: Switch to running Shiny app with Calcite UI, trigger validation with a bad input, fix it, submit, show result
Script: R users are a mathy bunch, but we also love building data-driven applications using the Shiny framework. The R-ArcGIS Bridge now integrates with Esri's Calcite Design System, so we can build full stack apps in R that fit right into the Esri ecosystem. We can even integrate Simon's validation directly into our own application.

something something about the app

Time: 1:05-1:15
Visual: Result on screen
Script: Web tools enable users of any language to harness complex workflows in the ArcGIS system. The R-ArcGIS Bridge continues to grow and integrate directly into this system.


----

- langauge agnostic way to sahre complex workflows
- im r user 
- newest release of r-bridge suports geoprocessing services directly
- we can leverage simons workflow without reinventing the wheel
- r users are mathy bunch but also love building data-driven applications using the shiny framework
- the r-arcgis bridge has also released an integration with Esri's calcite design system
- we can build full stack apps in R the fit hte brand blahblah
- we can integrate simons validation and tooling into our own bespoke application
- the validation endpoint is now part of our application
- web tools enable users of all langauges to harness complex workflows in the arcgis system
- the R-ArcGIS Bridge continues to grow and integrate directly into this sytem.


----

Two arguments
input features:
  - the smaller layer
target features: 
  - the thing we are inserting into

## GP Service definition
  
```json
{
"displayName": "Upload",
"executionType": "esriExecutionTypeAsynchronous",
"name": "UploadFeatureClassToGDB",
"description": "Append features from an input layer to a target layer (enterprise/file GDB). Uses GPFeatureRecordSetLayer for both input and target. Describe-only validation with dynamic extent checks (Percent Overlap by default).",
"helpUrl": "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/directories/arcgisoutput/Upload_GPServer/Upload/UploadFeatureClassToGDB.htm",
"category": "",
"parameters": [
  {
   "parameterType": "esriGPParameterTypeRequired",
   "displayName": "Input Features (Layer)",
   "defaultValue": {},
   "dataType": "GPFeatureRecordSetLayer",
   "name": "in_features",
   "description": "",
   "category": "",
   "direction": "esriGPParameterDirectionInput"
  },
  {
   "parameterType": "esriGPParameterTypeRequired",
   "displayName": "Target Features (Layer)",
   "defaultValue": {},
   "dataType": "GPFeatureRecordSetLayer",
   "name": "target_features",
   "description": "",
   "category": "",
   "direction": "esriGPParameterDirectionInput"
  },
  {
   "parameterType": "esriGPParameterTypeDerived",
   "displayName": "Upload Status",
   "defaultValue": null,
   "dataType": "GPBoolean",
   "name": "status",
   "description": "",
   "category": "",
   "direction": "esriGPParameterDirectionOutput"
  }
]
}
```


## Example validation input
```json
{
"validationResults": [
{
"isAltered": true,
"hasBeenValidated": true,
"isEnabled": true,
"name": "in_features",
"message": {
"code": 0,
"description": "The input has 2359 feature, which is over 100.",
"type": "warning"
},
"value": {"url": "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/env_small_spill_investigations/FeatureServer/1"}
},
{
"isAltered": false,
"hasBeenValidated": true,
"isEnabled": true,
"name": "target_features",
"message": {
"code": 735,
"description": "ERROR 000735: Target Features (Layer): Value is required",
"type": "error"
}
},
{
"isAltered": false,
"hasBeenValidated": true,
"isEnabled": true,
"name": "status",
"value": null
}
],
"additionalMessages": [{
"code": 735,
"description": "The input has 2359 feature, which is over 100.\nERROR 000735: Target Features (Layer): Value is required",
"type": "error"
}]
}
```
