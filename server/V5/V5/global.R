library(shiny)
library(sunburstR)
library(R6)
library(httr)
library(XML)
library(shinyWidgets)
library(plotly)
library(dygraphs)
library(leaflet)
library(shinyTree)
library(jsonlite)
library(sankeyD3)
library(timevis)
library(maptools)
library(rgdal)
library(sp)
library(survival)
library(survminer)
library(visNetwork)
library(DT)


GLOBALinvalidRequest <- "Error : invalid request"
GLOBALinvalidRequest <- "Erreur : requête impossible à réaliser"




### URL connection : 
load("GLOBALurlserver.rdata")

## Leaflet : 
GLOBALmapObjectControls = "mapObjectControls"
GLOBALcontrols <- "controls"
GLOBALmapId <- "mapId"
GLOBALlayerControl <- "layerControl"

# a logger to log message in file
GLOBALlogFolder <- "./logs/"
GLOBALqueriesFolder <- "./queries/"
GLOBALqueriesListFile <- "queriesListFile.csv"

# shapeFiles
GLOBALshapeFileFolder <- "./shapeFiles/"


## sankey : 
GLOBALeventTabSetPanelSankey <- "eventTabsetSankey" # tabsetPanel id of events
GLOBALmainPanelSankeyId <- "mainPanelSankey"
GLOBALaddResultsTabSetPanelSankey <- "addResultsSankey" # !! same label and id !
GLOBALplotSankey <- "Plot Sankey"
GLOBALsankeyPloted <-  "Sankey Plotted"
GLOBALsankeyTutorial <- "To plot a Sankey diagram, choose two variables per event. 
You can't choose context variables for now"
GLOBALnoPredicateChosen <- "No variable selected"
GLOBALonlyOneEvent <- "Only one event detected. Sankey impossible to plot"

GLOBALeventTabSetPanel <- "eventTabset" # tabsetPanel id of events
GLOBALaddEventTabpanel <- "addEventTabpanel"
GLOBALsetQuery <- "setQuery"
GLOBALsearchEvents <- "searchEvents"
GLOBALdivQueryBuilder <- "QueryBuilderDiv"

#### CSS :
GLOBALliPredicateLabelClass = "liPredicateLabel" ## class for li of predicate label
GLOBALspanEventLabelClass = "spanEventClass"

GLOBALlang <- "fr"


#### timeline
GLOBALtimelineDiv <- "timelineDiv"

#### survie 
GLOBALsurvieDiv <- "survieDiv"

### label
if (GLOBALlang == "fr"){
  GLOBALaddEventTabpanel <- "Ajout un évènement"
  GLOBALremoveEventTabpanel <- "Retirer un évènement"
  GLOBALhide <- "Masquer"
  GLOBALshow <- "Afficher"
  
  # duration
  GLOBALminutes <- "minutes"
  GLOBALhours <- "heures"
  GLOBALdays <- "jours"
  GLOBALweeks <- "semaines"
  GLOBALmonths <- "mois"
  
  ## filterHierarchical 
  GLOBALvalidate <- "Valider le choix"
  
  ## boxplot
  GLOBALinitialBoxplot <- "valeurs initiales"
  GLOBALselectedBoxplot <- "valeurs sélectionnées"
  
  ## pieChart : 
  GLOBALinitialPieChart <- "valeurs initiales"
  GLOBALselectedPieChart <- "valeurs sélectionnées"
  
  ## TextInfo
  GLOBALvaluesSelectedOutOf <- "valeurs sélectionnées sur"
  
  ## hierarchy selection : 
  GLOBALnoselected <- "Sélectionnez une catégorie"
  GLOBALmanyselected <- "Merci de sélectionner une seule catégorie"
  GLOBALnoChoiceAvailable <- "Aucun choix possible"
  
  ## words
  GLOBALevent <- "évènements"
  GLOBALparcours <- "parcours de soins"
  GLOBALand <- "et"
  GLOBALselected <- "sélectionné(s)"
  GLOBALbetween <- "entre"
  
  ## instanceSelectionContext and Events : 
  GLOBALsearchContexts <- paste0("Rechercher des ",GLOBALparcours)
  GLOBALsearchEvents <- "Rechercher des évènements"
  
  ## context : 
  GLOBALupdateContext <- paste0("Choisir ces ",GLOBALparcours, " pour les ", GLOBALevent)
  
  ## leaflet : 
  GLOBALvoirlacarte <- "Voir la carte"
  GLOBALaddCircles <- "Ajout cercles"
  
  ## valeurs sélectionnées(description filter) : 
  GLOBALvaleursselected <- "valeur(s) sélectionnée(s)"
  
  ### QueryBuilder : 
  GLOBALqueryBuilder <- "Création de requêtes"
  GLOBALcontextDescription <- "Description du contexte"
  GLOBALeventsDescription <- "Description des évènements"
  GLOBALlinksBetweenEvents <- "Liens entre les évènements"
  GLOBALlinksDescription <- "Description des liens"
  GLOBALlabelSetQuery <- "Créer la requête"
  GLOBALlabelSearchEvents <- "Envoyer la requête"
  GLOBALcreateLink <- "Créer un nouveau lien"
  GLOBALsearchAttributes <- "Chercher des attributs"
  GLOBALlinksCreation <- "Création de liens"
  GLOBALnoLinkCreated <- "Aucun lien créé"
  GLOBALnoEventSelected <- "Aucun évènement sélectionné"
  GLOBALqueryLib <- "Libellé de la requête"
  GLOBALdeleteQuery <- "Supprimer la requête"
  
  ## sankey
  GLOBALchooseQuery <- "Choisir une requête"
  GLOBALsearchQueries <- "Rechercher des requêtes"
  GLOBALquery <- "Requête"
  GLOBALplotSankey <- "Créer un diagramme de Sankey"
  GLOBALsankeyPloted <-  "Diagramme de Sankey réalisé"
  GLOBALsankeyTutorial <- "Pour réaliser un diagramme de Sankey, choisir deux variables. Il n'est pas possible de choisir une variable du contexte pour le moment"
  GLOBALnoPredicateChosen <- "Aucune variable sélectionnée"
  GLOBALonlyOneEvent <- "Un seul évènement détecté. Sankey impossible à réaliser"
  
  ## Timeline
  GLOBALcontextDescription <- "Description du contexte"
  GLOBALeventDescription <- "Description de l'évènement"
  GLOBALvariableDescription <- "Description de la variable"
  GLOBALvariable <- "variable"
  GLOBALvalue <- "valeur"
  GLOBALtimelineViz <- "Visualisation d'une timeline"
  
  ## Survie
  GLOBALmakeSurvivalCurve <- "Make survival curve"
  
} else if (GLOBALlang == "en"){
  GLOBALaddEventTabpanel <- "Add an event"
  GLOBALremoveEventTabpanel <- "removeEventTabpanel"
  GLOBALhide <- "Hide"
  GLOBALshow <- "Show"
  
  # duration
  GLOBALminutes <- "minutes"
  GLOBALhours <- "hours"
  GLOBALdays <- "days"
  GLOBALweeks <- "weeks"
  GLOBALmonths <- "months"
  
  ## boxplot
  GLOBALinitialBoxplot <- "initial values"
  GLOBALselectedBoxplot <- "selected values"
  
  ## pieChart : 
  GLOBALinitialPieChart <- "initial values"
  GLOBALselectedPieChart <- "selected values"
  
  ## TextInfo
  GLOBALvaluesSelectedOutOf <- "values selected out of"
  
  ## hierarchy selection : 
  GLOBALnoselected <- "please, select one class"
  GLOBALmanyselected <- "please, select only one class"
  GLOBALnoChoiceAvailable <- "No choice available"
  
  ## words
  GLOBALevent <- "event(s)"
  GLOBALparcours <- "patients trajectories"
  GLOBALselected <- "selected"
  GLOBALand <- "and"
  GLOBALbetween <- "between"
  
  ## instanceSelectionContext and Events : 
  GLOBALsearchContexts <- paste0("Search ",GLOBALparcours)
  GLOBALsearchEvents <- "Search events"
  
  ## context : 
  GLOBALupdateContext <- paste0("Set these ",GLOBALparcours, " for ", GLOBALevent)
  
  ## filterHierarchical 
  GLOBALvalidate <- "Confirm"
  
  ## leaflet : 
  GLOBALvoirlacarte <- "See map"
  GLOBALaddCircles <- "Add circles"
  
  ## valeurs sélectionnées(description filter) : 
  GLOBALvaleursselected <- "values chosen"
  
  ### QueryBuilder
  GLOBALqueryBuilder <- "Query factory"
  GLOBALcontextDescription <- "Context description"
  GLOBALeventsDescription <- "Events description"
  GLOBALlinksBetweenEvents <- "Links between events"
  GLOBALlinksDescription <- "Links description"
  GLOBALlabelSetQuery <- "Create query"
  GLOBALlabelSearchEvents <- "Send query"
  GLOBALcreateLink <- "Create a new link"
  GLOBALsearchAttributes <- "Search attributes"
  GLOBALlinksCreation <- "Links factory"
  GLOBALnoLinkCreated <- "No link created between events"
  GLOBALnoEventSelected <- "No event selected"
  GLOBALqueryLib <- "Query label"
  GLOBALdeleteQuery <- "Delete query"
  
  
  ## Sankey
  GLOBALchooseQuery <- "Choose a query"
  GLOBALsearchQueries <- "Search queries"
  GLOBALquery <- "Query"
  
  ## Timeline
  GLOBALcontextDescription <- "Context description"
  GLOBALeventDescription <- "Event description"
  GLOBALvariable <- "predicate"
  GLOBALvalue <- "value"
  GLOBALtimelineViz <- "Timeline vizualisation"
  GLOBALvariableDescription <- "Variable description"
  
  ## Survie
  GLOBALmakeSurvivalCurve <- "Calculer la courbe de survie"
}
