FilterDate <- R6::R6Class(
  "FilterDate",
  inherit = Filter,
  
  public = list(
    observersList = list(),
    valueEnv = environment(),
    dateGraphics = NULL,
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      staticLogger$info("Creating a new FilterDate object")
      super$initialize(contextEnv, predicateName, dataFrame, parentId, where)
      dateValues <- DateValues$new(dataFrame$value)
      self$makeUI()
      self$dateGraphics <- DateGraphics$new(contextEnv,
                                            dateValues, 
                                            self$getDivFilterId(),
                                            where="beforeEnd")
    },
    
    updateDataFrame = function(){
      staticLogger$info("updateDataFrame of FilterDate")
      eventType <- self$contextEnv$instanceSelection$className
      terminologyName <- self$contextEnv$instanceSelection$terminology$terminologyName
      predicateName <- self$predicateName
      contextEvents <- self$contextEnv$instanceSelection$getContextEvents()
      self$dataFrame <- staticFilterCreator$getDataFrame(terminologyName, eventType, contextEvents, predicateName)
      self$dateGraphics$dateValues$setXTS(self$dataFrame$value)
      self$dateGraphics$updateDateRange()
      self$dateGraphics$remakePlot()
    },
    
    getEventsSelected = function(){
      minDate <- self$dateGraphics$dateValues$getMinDate()
      maxDate <- self$dateGraphics$dateValues$getMaxDate()
      values <- self$dateGraphics$dateValues$valueToDate(self$dataFrame$value)
      values <- as.Date(values, format="%Y-%m-%d")
      bool <- values >= minDate & values <= maxDate
      eventsSelected <- as.character(self$dataFrame$event[bool])
      return(eventsSelected)
    },
    
    getXMLpredicateNode = function(){
      tempQuery <- XMLSearchQuery$new()
      minDate <- self$dateGraphics$dateValues$getMinDate()
      minDate <- gsub("-","_",minDate)
      maxDate <- self$dateGraphics$dateValues$getMaxDate()
      maxDate <- gsub("-","_",maxDate)
      predicateNode <- tempQuery$makePredicateNode(predicateClass = "date",
                                                   predicateType = self$predicateName,
                                                   minValue = minDate,
                                                   maxValue = maxDate)
      return(predicateNode)
    },
    
    getDescription = function(){
      predicateLabel <- self$getPredicateLabel() ## FilterFunction
      description <- paste0("min: ",self$dateGraphics$dateValues$getMinDate(),
                            "  -  max: ", self$dateGraphics$dateValues$getMaxDate())
      lipredicate <- shiny::tags$li(predicateLabel, class=GLOBALliPredicateLabelClass,
                                    shiny::tags$p(description))
      return(lipredicate)
    },
    
    makeUI = function(){
      jquerySelector <- private$getJquerySelector(self$parentId)
      insertUI(selector = jquerySelector, 
               where = self$where,
               ui = self$getUI(),
               immediate = T)
    },
    
    getUI = function(){
      ui <- div(id = self$getDivId(),
                div(id = self$getDivFilterId()), ## end first div, 
                div(class="textOutputSelection",shiny::textOutput(self$getTextInfoId(),inline = T))
      )
      return(ui)
    }, 
    
    getObjectId = function(){
      return(paste0("FilterDate-",self$predicateName,"-",self$parentId))
    },
    
    getDivId = function(){
      return(paste0("div",self$getObjectId()))
    },
    
    getDivFilterId = function(){
      return(paste0("divFilter",self$getDivId()))
    },
    
    getGraphicsId = function(){
      return(paste0("Graphics",self$getDivId()))
    },
    
    getTextInfoId = function(){
      return(paste0("TextInfo",self$getDivId()))
    },
    
    removeUI = function(){
      jQuerySelector <- private$getJquerySelector(self$getDivId())
      removeUI(selector = jQuerySelector)
    },
    
    destroy = function(){
      staticLogger$info("Destroying FilterDate :", self$getObjectId())
      
      staticLogger$info("\t removing dateGraphics")
      if (!is.null(self$dateGraphics)){
        self$dateGraphics$destroy()
      }
      staticLogger$info("\t removing every observer")
      for (observer in self$observersList){
        staticLogger$info("\t \t done")
        observer$destroy()
      }
      self$observersList <- NULL
      
      staticLogger$info("\t removing UI")
      self$removeUI()
      staticLogger$info("End destroying FilterDate :", self$getObjectId())
    }
    
  ),
  
  private = list(
    
  )
)
