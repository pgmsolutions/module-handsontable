.handsontable$instances <- list()

# Create a new Handsontable 
Handsontable.create <- function(tableId, step, widgetId, height = 512, options = list()){
    # Prepare the label widget
    gui.setValue(step, widgetId, paste0('<div id="handsontable-', tableId, '" style="height: ', height ,'px"></div>'))

    # options names
    optionsNames = names(options);

    # Automatic dataframe -> list of lists
    if(is.data.frame(options$data)){
        if("rowHeaders" %in% optionsNames && options$rowHeaders == TRUE){
            options$rowHeaders = row.names(options$data);
        }
        if("colHeaders" %in% optionsNames && options$colHeaders == TRUE){
            options$colHeaders = colnames(options$data);
        }
        options$data = Handsontable.fromDF(options$data);
    }

    # Re-inject height to handsontable
    if(!("height" %in% optionsNames)){
        options$height = height;
    }

    # Create the table instance in the R side
    .handsontable$instances[[tableId]] <- list(
        id=tableId,
        step=step,
        height=height,
        data=options,
        events=list(
            onDidLoad=list(),
            onDidChangeValue=list(),
            onDidChangeSelection=list()
        )
    )

    # Ask JS if user load the page already when the table is here
    rpgm.sendToJavascript('handsontable/enterStep')
}

rpgm.on('didReceiveMessage', function(message, data){
    if(message == 'handsontable/onDidEnterStep'){
        # Check if a table exists in this step and load it
        for(table in .handsontable$instances){
            if(table$step[[2L]] == data$stepId){
                rpgm.sendToJavascript('handsontable/initialize', list(
                    tableId=table$id,
                    height=table$height,
                    data=table$data
                ))
            }
        }
    }
    else if(message == 'handsontable/onDidLoad'){
        .handsontable$emit(data$id, 'onDidLoad', list())
    }
    else if(message == 'handsontable/onDidChangeValue'){
        .handsontable$emit(data$id, 'onDidChangeValue', list(value=data$value, columns=data$cols, rows=data$rows))
    }
    else if(message == 'handsontable/onDidChangeSelection'){
        .handsontable$emit(data$id, 'onDidChangeSelection', list(selection=data$selection))
    }
})