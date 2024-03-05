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

Handsontable.fromMatrix <- function(mat){
    
}