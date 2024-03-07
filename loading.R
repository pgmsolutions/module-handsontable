source(rpgm.pgmFilePath('modules/handsontable/main.R'))

exampleDF <- mtcars

# Initialize the table widget with a data frame
Handsontable.create(
    'main',
    rpgm.step('main', 'handsontable'),
    'table',
    height = 512,
    # Options are the Handsontable options, see https://handsontable.com/docs/javascript-data-grid/api/options/
    options = list(
        data=exampleDF,
        rowHeaders=TRUE,
        colHeaders=TRUE,

        autoColumnSize=TRUE,
        columnSorting=TRUE,
        manualColumnResize=TRUE,

        autoWrapRow=TRUE,
        autoWrapCol=TRUE,

        filters=TRUE,
        dropdownMenu=TRUE,

        licenseKey='non-commercial-and-evaluation'
    )
);

# The table is loaded
Handsontable.on('main', 'onDidLoad', function(){
});

# User changed the value of the table
Handsontable.on('main', 'onDidChangeValue', function(value, columns, rows){
    exampleDF <<- value
    gui.setValue("this", "data", paste0("Sum of first column: ", sum(exampleDF$mpg)))
});

# Selection changed!
Handsontable.on('main', 'onDidChangeSelection', function(selection){
    if(is.null(selection)){
        gui.setValue("this", "selection", "Selection: nothing is selected!")
    }
    else {
        gui.setValue("this", "selection", paste0("Selection: from (",selection[[1L]],",",selection[[2L]],") to (",selection[[3L]],",",selection[[4L]],")!"))
    }
});