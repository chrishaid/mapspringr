#' Impute prior spring RIT from current fall 
#' 
#' Models require 5 predictors \code{TestRITScore.x}, \code{Goal1RitScore.x},
#' \code{Goal2RitScore.x}, \code{Goal3RitScore.x}, \code{Goal4RitScore.x},
#' \code{TestDurationMinutes.x}, \code{PercentCorrect.x}, and \code{Grade},
#' as well as a subject indicator.
#' 
#' @export
#' @import randomForest
#' @param input data passed on as \code{newdata} to \code{\link{predict}}.  
#' requirese the following predictors: \code{TestRITScore.x}, \code{Goal1RitScore.x},
#' \code{Goal2RitScore.x}, \code{Goal3RitScore.x}, \code{Goal4RitScore.x},
#' \code{TestDurationMinutes.x}, \code{PercentCorrect.x}, and \code{Grade}
#' @param subject character vector indicating \code{"reading"} or \code{"math"}
#' @param na_replacment numerical value used to replace \code{NA}s in data data. 
#' @examples 
#' require(mapvisuals)
#' require(dplyr)
#' data(nweamap)
#' 
#' map_mv <- nweamap %>% filter(MeasurementScale=="Reading") %>%
#'    mapvizer
#'    
#' test_data<-map_mv %>% head(10)
#' 
#' impute_spring(test_data, subject="reading")
impute_spring <- function(input, subject="reading", na_replacement=-1){
  

  # input can either be csv file or data  
  newdata <- if(is.character(input) && file.exists(input)){
    read.csv(input)
  } else {
    as.data.frame(input)
  }
  
  cols<-names(newdata)
  
  # validation
  stopifnot("TestRITScore.x" %in% cols)
  stopifnot("Goal1RitScore.x" %in% cols)
  stopifnot("Goal2RitScore.x" %in% cols)
  stopifnot("Goal3RitScore.x" %in% cols)
  stopifnot("Goal4RitScore.x" %in% cols)
  stopifnot("TestDurationMinutes.x" %in% cols)
  stopifnot("PercentCorrect.x" %in% cols)
  stopifnot("Grade" %in% cols)
  
  
  # recode any NA data
  for (col in cols){
    newdata[,col]<-ifelse(is.na(newdata[,col]) | 
                            newdata[,col]=="NA", na_replacement, newdata[,col])
  }
  
  #tv_model is included with the package
  if(subject=="reading"){
    predicted<-predict(rf_reading, newdata = newdata, predict.all=TRUE)
  } else {
    predicted<-predict(rf_math, newdata = newdata, predict.all=TRUE)
  }
  pred_sd<-apply(predicted$individual, 1, sd)
  pred_mean<-predicted$aggregate
  pred_high<-pred_mean + 2*pred_sd
  pred_low<-pred_mean - 2*pred_sd
  
  newdata$predict_spring_RIT<-pred_mean
  newdata$predict_spring_RIT_low<-pred_low
  newdata$predict_spring_RIT_high<-pred_high
  newdata$predict_spring_RIT_SD<-pred_sd
  
  newdata
}