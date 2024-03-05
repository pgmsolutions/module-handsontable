source(rpgm.pgmFilePath('modules/handsontable/main.R'))

# Initialize the table widget
Handsontable.create(
    'main',
    rpgm.step('main', 'handsontable'),
    'table',
    height = 512,
    options = list(
        data=mtcars,
        rowHeaders=TRUE,
        colHeaders=TRUE,

        autoWrapRow=TRUE,
        autoWrapCol=TRUE,

        filters=TRUE,
        dropdownMenu=TRUE,

        licenseKey='non-commercial-and-evaluation'
    )
);

Handsontable.on('main', 'onDidLoad', function(){
});

Handsontable.on('main', 'onDidChangeValue', function(value, columns, rows){
    cat(value)
    gui.setValue("this", "data", "changed!")
});

Handsontable.on('main', 'onDidChangeSelection', function(selection){
    if(is.null(selection)){
        gui.setValue("this", "selection", "Selection: nothing is selected!")
    }
    else {
        gui.setValue("this", "selection", paste0("Selection: from (",selection[[1L]],",",selection[[2L]],") to (",selection[[3L]],",",selection[[4L]],")!"))
    }
});