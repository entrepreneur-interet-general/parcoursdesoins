# source("global.R")
server <- function(input,output,session){
  source("classes/logger/STATICLoggerOO.R",local = T)
  staticLogger <- STATIClogger$new()
  
  ## closing logger connection when user disconnect
  session$onSessionEnded(function() {
    staticLogger$close()
  })
  
  staticLogger$info("Loading classes ...")
  
  source("classes/queries/ConnectionOO.R",local=T)
  GLOBALcon <- Connection$new()
  
  source("classes/queries/GetFileOO.R",local=T)
  
  source("classes/terminology/STATICterminologyInstancesOO.R",local=T)
  source("classes/terminology/TerminologyOO.R",local=T)
  staticTerminologyInstances <- STATICterminologyInstances$new()
  
  # test <- staticTerminologyInstances$getTerminologyByClassName("Event")
  # voir<-  test$getPredicateDescriptionOfEvent("Event")
  # test$mainClassName
  # test$predicateDescription
  source("classes/queries/STATICmakeQueriesOO.R",local=T)

  source("classes/queries/XMLCountQueryOO.R",local=T)
  source("classes/queries/XMLDescribeQueryOO.R",local=T)
  source("classes/queries/XMLDescribeTerminologyQueryOO.R",local = T)
  source("classes/queries/XMLqueryOO.R",local=T)
  source("classes/queries/XMLSearchQueryOO.R",local=T)
  source("classes/queries/XMLSearchQueryTerminologyOO.R",local=T)
  

  source("classes/superClasses/uiObject.R",local=T)
  source("classes/filter/FilterHierarchicalOO.R",local = T)
  source("classes/filter/FilterHierarchicalEventOO.R",local = T)
  source("classes/events/EventTabpanelOO.R",local=T)
  source("classes/events/ListEventsTabpanelOO.R",local=T)
  source("classes/buttonFilter/ButtonFilterOO.R",local=T)
  source("classes/filter/FilterOO.R",local=T) ## order matters ! 
  source("classes/filter/FilterNumericOO.R",local=T)
  source("classes/filter/FilterNumericDurationOO.R",local=T)
  source("classes/graphics/NumericGraphicsOO.R",local = T)
  source("classes/values/NumericValuesOO.R",local = T)

  source("classes/filter/FilterCategoricalOO.R",local = T)
  source("classes/graphics/CategoricalGraphicsOO.R",local = T)
  source("classes/values/CategoricalValuesOO.R",local=T)
  
  source("classes/filter/FilterDate.R",local = T)
  source("classes/graphics/DateGraphics.R",local = T)
  source("classes/values/DateValuesOO.R",local=T)
  
  source("classes/events/InstanceSelection.R",local = T)
  source("classes/events/InstanceSelectionEvent.R",local = T)
  source("classes/events/InstanceSelectionContext.R",local = T)
  # an object to help others objects to create Filter Object
  source("classes/filter/STATICfilterCreatorOO.R",local = T)
  staticFilterCreator <- STATICfilterCreator$new()
  
  ## leaflet : 
  source("classes/leaflet/MapObjectOO.R",local = T)
  source("classes/filter/FilterSpatialPointOO.R",local=T)
  source("classes/filter/FilterSpatialPolygon.R",local=T)
  GLOBALmapObject <- MapObject$new()
  
  # an object to help others object to make queries
  source("classes/queries/STATICmakeQueriesOO.R",local=T)
  staticMakeQueries <- STATICmakeQueries$new()
  
  GLOBALlistEventTabpanel <- ListEventsTabpanel$new()
  
  source ("classes/queries/QueryVizOO.R",local = T)
  
  source("classes/queryBuilder/LinkEventsOO.R",local = T)
  source("classes/queryBuilder/LinkDescriptionOO.R",local=T)
  source("classes/queryBuilder/EventDescriptionOO.R",local=T)
  source("classes/queryBuilder/ContextDescriptionOO.R",local = T)
  source("classes/queryBuilder/QueryBuilderOO.R",local = T)
  
  source("classes/Result/ResultOO.R",local = T)
  source("classes/Result/ListResultsOO.R",local = T)
  source("classes/searchQueries.R",local=T)
  source("classes/sankey/SankeyOO.R",local = T)
  
  source("classes/timeLines/HandleTimelinesOO.R",local=T)
  source("classes/timeLines/TimelineOO.R",local=T)
  
  ## source("classes/survie/Survie.R",local = T)
  
  source("classes/HideShowButtons.R",local = T)
  
  source("classes/queries/STATICqueriesListOO.R",local=T)
  
  staticQueriesList <- STATICqueriesList$new()
  
  # GLOBALlistResults <- ListResults$new()
  # 
  # load("tempQuery2.rdata")
  # result <- Result$new(xmlSearchQuery)
  # GLOBALlistResults$addResult(result)
  
  GLOBALSankeylistEventTabpanel <- ListEventsTabpanel$new()
  sankey <- Sankey$new(GLOBALmainPanelSankeyId, "beforeEnd")
  
  # survie <- Survie$new(GLOBALsurvieDiv,"beforeEnd")
  
  
  GLOBALhandleTimelines = HandleTimelines$new(parentId = GLOBALtimelineDiv, 
                                              where = "beforeEnd")
  
  ### Context : 
  staticLogger$info("creating Context...")
  # get a sample ...
  # pSamples <- c("p92776","p54767","p110814","p59452","p139838") ### pmsi
  pSamples <- paste0("p",1:10000)
  contextEvents <- data.frame(context=pSamples,event=pSamples)
  # contextEvents <- data.frame(context=paste0("p",1:1000),event=paste0("p",1:1000))
  parentId = "contextId"
  where = "beforeEnd"
  GLOBALcontextEnv <- new.env()
  GLOBALcontextEnv$eventNumber <- 0
  terminology <- staticTerminologyInstances$terminologyInstances$Graph
  GLOBALcontextEnv$instanceSelection <- InstanceSelectionContext$new(contextEnv = GLOBALcontextEnv, 
                                                        terminology = terminology, 
                                                        className = "Graph", 
                                                        contextEvents = contextEvents, 
                                                        parentId = parentId, 
                                                        where = where)
  rm(contextEvents)
  staticLogger$info("ContextEnv added")
  
  ### must be created after GlobalContext:
  parentId <- GLOBALdivQueryBuilder
  where <- "beforeEnd"
  GLOBALqueryBuilder <- QueryBuilder$new(parentId, where)
  
  observeEvent(input[[GLOBALaddEventTabpanel]],{
    staticLogger$user("addEventTabpanel clicked")
    nClick <- input[[GLOBALaddEventTabpanel]]
    ## create new Tabpanel :
    eventTabpanel <- EventTabpanel$new(eventNumber=nClick,
                                       context = GLOBALcontextEnv$instanceSelection$context,
                                       tabsetPanelId = GLOBALeventTabSetPanel)
    eventTabpanel$setHierarchicalObject()
    GLOBALlistEventTabpanel$addEventTabpanel(eventTabpanel)
    GLOBALqueryBuilder$linkDescription$updateSelectionLink() ## add event to linkEvent
    GLOBALqueryBuilder$eventDescription$insertNewDivEvent()
  })
}

#o$destroy()

# 
# output$show_inputs <- renderTable({
#   AllInputs()
# })

#eventTabpanel$addHierarchicalObserver()
# output$sunburst0 <- renderSunburst({
#   add_shiny(sunburst(hierarchy4sunburst,colors = hierarchy4sunburst$color, count=T,legend = list(w=200)))
# })
# 
# selection <- reactive({
#   if (is.null(input$sunburst0_click)){
#     return(NULL)
#   }
#   print(input$sunburst0_click)
#   input$sunburst0_click
# })
# 


