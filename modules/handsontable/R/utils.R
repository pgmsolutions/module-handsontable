Handsontable.fromDF <- function(df){
    final <- list();
    for(i in 1:nrow(df)){
        ln <- list();
        for(j in 1:ncol(df)){
            ln[[j]] <- df[i,j]
        }
        final[[i]] <- ln;
    }
    return(final);
}

Handsontable.getColumnsFromDF <- function(df){
    cols <- list()
    for(i in 1:ncol(df)){
        cols[[i]] <- list(
            type=Handonstable.rTypeToTableType(df[[i]])
        )
    }
    return(cols);
}

Handonstable.rTypeToTableType <- function(var){
    if(typeof(var) == "logical"){
        return("checkbox");
    }
    if(typeof(var) == "double" || typeof(var) == "integer"){
        return("numeric");
    }
    return("text");
}

Handsontable.injectRowNames <- function(df, columnName){
    rows <- row.names(df)
    cols <- colnames(df)
    df[columnName] <- rows
    df <- df[, c(columnName, cols)]
    row.names(df) <- NULL
    return(df)
}