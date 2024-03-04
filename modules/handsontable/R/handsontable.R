.handsontable$instances <- list()

Handsontable.create <- function(tableId, step, widgetId, height = 512, data = list()){
    gui.setValue(step, widgetId, paste0('<div id="handsontable-', tableId, '" style="height: ', height ,'px"></div>'))
    .handsontable$instances[[tableId]] <- list(
        id=tableId,
        step=step,
        height=height,
        data=data,
        events=list(
            didLoad=list(),
            didChangeValue=list(),
            didChangeSelection=list()
        )
    )
    rpgm.sendToJavascript('handsontable/enterStep')
}

rpgm.on('didReceiveMessage', function(message, data){
    if(message == 'handsontable/onDidEnterStep'){
        # Check if a table exists in this step and load it
        for(table in .handsontable$instances){
            if(table$step[[2L]] == data$stepId){
                cat("FOUNNNNNNNNNNNNNNNNNNNNNNND")
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
        .handsontable$emit(data$id, 'onDidChangeValue', list(data=data))
    }
    else if(message == 'handsontable/onDidChangeSelection'){
        .handsontable$emit(data$id, 'onDidChangeSelection', list(data=data))
    }
})