# script to create random forest models.  
# There is one for math and one for reading

# map_fs is chicago data and there not inluded with the package.



# simple wrapper for FR
run_rf <- function(formula, 
                   .data, 
                   na.replacement=-1, 
                   pct_training=.75){
  df <- model.frame(formula, .data) # suubsets data fram based on formula
  y <- df[1] # response varialbe
  X <- df[-1] # model matrix (or featers)
  
  # replace NAs in features with na.replacement value
  for (col in names(X)){
    X[,col]<-ifelse(is.na(X[,col]) | 
                      X[,col]=="NA", na.replacement, X[,col])
  }
  
  # separate y and X int test and train
  
  in_training_set <- createDataPartition(y[,1], p=pct_training, list=FALSE)
  
  y_train <- y[in_training_set,]
  X_train <- as.data.frame(X[in_training_set,])
  colnames(X_train) <- names(X)
  
  y_test <- y[-in_training_set,]
  X_test <- as.data.frame(X[-in_training_set,])
  colnames(X_test) <- names(X)
  
  # RF
  require(randomForest)
  # simply a rapper around randomforest  
  fit_rf <-  randomForest(y=y_train,
                          x=X_train,
                          mtry=1,
                          ntree=1000
                          )
  fit_rf # return
}


# reading ####
rf_reading<- run_rf(TestRITScore.y ~ 
         TestRITScore.x*Grade + 
         Goal1RitScore.x +
         Goal2RitScore.x +
         Goal3RitScore.x +
         Goal4RitScore.x +
         TestDurationMinutes.x +
         PercentCorrect.x 
       , 
       .data=map_fs_reading)

# math ####
rf_math<- run_rf(TestRITScore.y ~ 
                      TestRITScore.x + 
                      Goal1RitScore.x +
                      Goal2RitScore.x +
                      Goal3RitScore.x +
                      Goal4RitScore.x +
                      TestDurationMinutes.x +
                      PercentCorrect.x + 
                      Grade,
                    .data=map_fs_math)

save(rf_reading, rf_math, file="data/rf_models.Rda")
