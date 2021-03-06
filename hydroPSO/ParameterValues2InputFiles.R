################################################################################
#                       ParameterValues2InputFiles                             #
################################################################################
# Purpose    : To write several values into several plain text files, by using #
#              the filenames, row and column positions defined in the          #
#              'ParamFiles.fname' file                                         #
################################################################################
# Output     : A mofified text file ('filename')                               #
################################################################################
# Modified from the hydroPSO
################################################################################

ParameterValues2InputFiles <- function(NewValues,
                                       ParamFiles.fname="ParamFiles.txt",
                                       verbose=TRUE
) {
      require(doParallel)
  cl <- makeCluster(3)
  registerDoParallel(cl)
      # Checking 'NewValues'
      if ( is.na( match(class(NewValues), c("numeric", "integer") ) ) )
            stop("Invalid argument: class(NewValues) has to be in c('numeric', 'integer')") 
      
      # Number of values provided by the user
      nval <- length(NewValues)
      
      # Reading the file with the location of the paramters
      ParamFiles <-  read.paramfile(file=ParamFiles.fname)
      
      n1 <- length(levels(as.factor(ParamFiles[,1]))) # Number of Param IDs
      n2 <- length(levels(as.factor(ParamFiles[,2]))) # Number of Param Names
      if ( n1 != n2)
            stop( paste("In '", ParamFiles.fname, "' : Number of 'ParameterNmbr' != Number of 'ParameterName' (", n1, " != ", n2, ")", sep="" ) ) 
      if ( n1 != nval)
            stop( paste("Number of Parameters != Number of Values' (", n1, " != ", nval, ")", sep="" ) )
      
      # Number of files that have to be changed
      nfiles <- nrow(ParamFiles)
      
      # Loop in all the files that have to be changed
      foreach (i = 1:nfiles, .export = "ModifyInputFile") %dopar% {
            
            ParamID   <- ParamFiles[i,1]
            ParamName <- ParamFiles[i,2]
            filename  <- ParamFiles[i,3]
            lrow      <- ParamFiles[i,4]
            col.ini   <- ParamFiles[i,5]
            col.fin   <- ParamFiles[i,6]
            decimals  <- ParamFiles[i,7]
            
            ModifyInputFile(ParamID=ParamName, newvalue= NewValues[ParamID], 
                            filename=filename, row=lrow, col.ini= col.ini, col.fin=col.fin, 
                            decimals=decimals, verbose=verbose)
            
      } # FOR end
      print ("================================ Parameter replaced")
      #stopCluster(cl)
      
} # 'ParameterValues2InputFiles' end

