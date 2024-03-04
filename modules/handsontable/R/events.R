.handsontable$emit <- function(tableId, event, data){
    for(table in .handsontable$instances){
        if(table$id == tableId){
            for(entry in table$events[[event]]){
                do.call(entry, data[names(data) != "id"]);
            }
        }
    }
}

# Add a new event listener. See the [Events](#events) section for more information.
Handsontable.on <- function(tableId, event, callback){
    for(table in .handsontable$instances){
        if(table$id == tableId){
            .handsontable$instances[[table$id]]$events[[event]] <- append(table$events[[event]], callback);
        }
    }
}

# Remove an existing event listener. See the [Events](#events) section for more information.
Handsontable.off <- function(tableId, event, callback){
    for(table in .handsontable$instances){
        if(table$id == tableId){
           .handsontable$instances[[table$id]]$events[[event]] <- table$events[[event]][table$events[[event]] != callback];
        }
    }
}