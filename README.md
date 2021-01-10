# appsilonshinyapp

Project Scope:

To build a Shiny Application using martime data. 
To find the observation when ship sailed the longest distance between two consecutive observations. 
If there is a situation when a vessel moves exactly the same amount of meters, please select the most recent.  
Display that on the map - show two points, the beginning and the end of the movement. The map should be created using the leaflet library. Changing type and vessel name should re-render the map and the note

The size of file ~ 400 MB 

Computational Calculations: 

The Computational Calculations  involve sorting , appending columns  searching and binding data 
1) Load the data on cloud and import part of data in shiny application
2) Compute in R and import the file with few observations in Shiny 

The second method is prefered for this app 

Logic To Calculate the Distance: 
1) Based on difference  Longitude and Lattitude 
2) By the common formula Distance = Speed * Time --- Here time difference between the two successive observations is calculated and multiplied by Speed. 

The second method is used for calculations in this app. While analysing it for random sample from data it appears to be overestimating the distance
More accurate info may be possible with first, currently working on it. 

Grouping of Data:

The data is grouped by ship_type(Cargo) , shipname and destination then data is updated as per scope. 

Further Work: 

Leaerning Shiny Modules and shiny sementic to enchane the application. 
