fonctions_tree <- new.env()

fonctions_tree$new_treeboutton <- function(event){
  div <- div(id=event$get_treebouttonid(), value=event$get_event_number(), class="box",
             h4(event$get_h4(), class="h4-treeboutton", value=event$get_event_number()),
             shinyTree(event$get_treeid(), checkbox = TRUE),
             #verbatimTextOutput("selTxt"),
             div(class="bouttons",
             actionButton(event$get_addpreviousid(), "<"),
             actionButton(event$get_addnextid(), ">"),
             actionButton(event$get_validateid(), "V"),
             actionButton(event$get_removeid(), "X")
  ))
return(div)
}


## rmatch : fonction trouvée sur stackoverflow
# https://stackoverflow.com/questions/27890388/r-get-element-by-name-from-a-nested-list
fonctions_tree$rmatch <- function(x, name) {
  pos <- match(name, names(x))
  if (!is.na(pos)) return(x[[pos]])
  for (el in x) {
    if (class(el) == "list") {
      out <- Recall(el, name)
      if (!is.null(out)) return(out)
    }
  }
}

fonctions_tree$get_hierarchylistN = function(hierarchyliste, lowestlevel_vector){
  require(jsonlite)
  ## fonction récursive pour récupérer tous les noms de la liste :  
  getnames_of_liste <- function(liste){
    if (is.list(liste)){
      nom <- names(liste)
      noms <- NULL
      for (i in nom){
        noms <- append(noms,getnames_of_liste(liste[[i]]))
      }
      return(c(nom,noms))
    } else 
    {
      return(NULL)
    }
  }
  
  ### on a une hiérarchie
  # pour le niveau le plus bas de la hiérarchie, on connait le nombre de valeurs :
  lowestlevel <- unlist(hierarchyliste)
  tab <- table(lowestlevel_vector)
  ## vérifications : 
  bool <- all(names(tab) %in% lowestlevel)
  if (!bool){
    stop("certaines valeurs ne correspondent pas au niveau le plus bas de la hiérarchie")
  }
  tab <- data.frame(classe=names(tab), value=as.numeric(tab))
  
  ## il faut ajouter aux noms de la hiérarchie le nombre de valeurs
  noms <- getnames_of_liste(hierarchyliste)
  bool <- noms%in%lowestlevel ## on enlève le lowest levels
  noms <- noms[!bool]
  noms <- rev(noms) ## rev permet de classer du plus petit niveau de la hiérarchie
  ## au plus haut ; important car ensuite on itère dans cet ordre pour déterminer le nombre
  superclasse <- data.frame (classe=noms, value=NA)
  
  tab <- rbind(tab, superclasse) ## on a les valeurs pour le lowest level, on détermine pour les niveaux au-dessus
  
  for (i in noms){
    fils <- names(fonctions_tree$rmatch(hierarchyliste, i))
    tab$value[tab$classe == i] <- sum(tab$value[tab$classe %in% fils])
  }
  tab$newname <- paste0(tab$classe,"(",tab$value,")")
  
  ## il faut maintenant remplacer les valeurs ...
  # je n ai pas trouvé de solution plus élégante que d'écrier le JSON dans un txt
  # puis de remplacer les chaines de charactere
  txt <- jsonlite::prettify(jsonlite::toJSON(hierarchyliste))
  txt <- unlist(strsplit(as.character(txt),"\n"))
  
  i <- 1
  for (i in 1:nrow(tab)){
    oldname <- paste0("\"",as.character(tab$classe[i]),"\"")
    newname <- paste0("\"",tab$newname[i],"\"")
    numligne <- min(which(grepl(oldname, txt)))
    txt[numligne] <- gsub(oldname,newname,txt[numligne])
  }
  
  hierarchylisteN <- jsonlite::fromJSON(txt)
  return(hierarchylisteN)
}


#### Algo pour l'agrégation selon les choix de l'utilisateur : 
## 1) on commence par lister tous les éléments pour chaque niveau d'agrégat choisi
## 2) on compte le nombre d'éléments dans chaque niveau d'agrégat
## 3) Si un élément apparait 2 fois : on sélectionne le niveau d'agrégat le plus petit

fonctions_tree$get_df_type_selected <- function(hierarchyliste, choix){
  
  ## 1) 
  elementsNiveaux <- lapply(choix, function(x){
    as.character(unlist(fonctions_tree$rmatch(hierarchyliste, x)))
  })
  ## 2) 
  Nelements <- unlist(lapply(elementsNiveaux, length))
  bool <- Nelements == 0
  if (any(bool)){
    cat(choix[bool], " non trouvé dans la hiérarchie \n")
    return(NULL)
  }
  
  dfagregation <- NULL
  i <- 1
  for (i in 1:length(elementsNiveaux)){
    ajout <- data.frame(events = unlist(elementsNiveaux[[i]]), Ngroupe = Nelements[i], agregat = choix[i],
                          row.names = NULL)
    dfagregation <- rbind(dfagregation, ajout,row.names=NULL)
  }
  
  ## 3)
  ## un élément est dans plusieurs groupes pour l'agrégation : choix du groupe le plus petit
  tab <- tapply(dfagregation$Ngroupe, dfagregation$events, min)
  tab <- data.frame(events = names(tab), Ngroupe=as.numeric(tab))
  dfagregation <- merge (dfagregation, tab, by=c("Ngroupe","events"))
  bool <- length(unique(dfagregation$events)) == nrow(dfagregation)
  if (!bool){
    warning("Un event est rangé dans plusieurs groupes pour l'agrégation")
  }
  
  return(dfagregation)
}
