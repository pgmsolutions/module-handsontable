source(rpgm.pgmFilePath('modules/handsontable/main.R'))

# Create an example data frame for the app with number, checkboxes and strings
createExampleDF <- function(){
    exampleDF <- mtcars

    # Transform the vs column with 0 and 1 to TRUE or FALSE
    temp <- c()
    for(i in 1:nrow(mtcars)){
        temp <- c(temp, exampleDF$vs[[i]] == 1)
    }
    exampleDF$vs <- temp;

    # Put the rows names to a first column
    exampleDF$Name <- row.names(exampleDF)
    exampleDF <- exampleDF[, c('Name', 'mpg', 'cyl', 'disp', 'hp', 'drat', 'wt', 'qsec', 'vs', 'am', 'gear', 'carb')]
    row.names(exampleDF) <- NULL

    return(exampleDF)
}
exampleDF <- createExampleDF();

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

        rowHeaderWidth=50,
        colWidths=c(100, 100, 150, 100, 100, 100, 100, 50, 50, 50, 50),
        width='100%',
        stretchH='all', # define the algorithm to use when the container is larger than the grid

        autoWrapRow=TRUE,
        autoWrapCol=TRUE,

        filters=TRUE,
        dropdownMenu=TRUE,

        licenseKey='non-commercial-and-evaluation' # You should enter your commercial license key here.
    )
);

# The table is loaded
Handsontable.on('main', 'onDidLoad', function(){
});

# User changed the value of the table
Handsontable.on('main', 'onDidChangeValue', function(value, columns, rows){
    exampleDF <<- value # value is the data.frame from Handsontable
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