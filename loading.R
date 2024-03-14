source(rpgm.pgmFilePath('modules/handsontable/main.R'))

#######################################################################################################
#  ___                     _       _ 
# | __|_ ____ _ _ __  _ __| |___  / |
# | _|\ \ / _` | '  \| '_ \ / -_) | |
# |___/_\_\__,_|_|_|_| .__/_\___| |_|
#                    |_|             
#######################################################################################################
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
    exampleDF <- Handsontable.injectRowNames(exampleDF, 'Name')
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

reset <- function(){
    exampleDF <<- createExampleDF()
    Handsontable.update('main', list(data=exampleDF))
}

#######################################################################################################
#   ___                     _       ___ 
#  | __|_ ____ _ _ __  _ __| |___  |_  )
#  | _|\ \ / _` | '  \| '_ \ / -_)  / / 
#  |___/_\_\__,_|_|_|_| .__/_\___| /___|
#                     |_|               
#######################################################################################################
# The second handsontable with dropdown selection

# Create colors list and generate colors for cars
carColors <- c('Green', 'Yellow', 'Red', 'Blue', 'White', 'Black', 'Magenta', 'Cyan', 'Purple', 'Pink')
getRandomColor <- function(){
    return(carColors[[round(runif(1, 1, length(carColors)))]])
}
dropdownExample <- mtcars
clrs <- c()
for(i in seq(1:32)){
    clrs <- c(clrs, getRandomColor())
}
dropdownExample$Color <- clrs

# Name column
dropdownExample <- Handsontable.injectRowNames(dropdownExample, 'Name')

# Generate the column property to add the dropdown options to the colors column
columns <- Handsontable.getColumnsFromDF(dropdownExample)
colorsColumnIndex <- grep("Color", colnames(dropdownExample))
columns[[colorsColumnIndex]] <- list(
    type='dropdown',
    source=carColors
)

# Create the table
Handsontable.create(
    'example2',
    rpgm.step('main', 'handsontable'),
    'example2',
    height = 512,
    options = list(
        data=dropdownExample,
        columns=columns, # override default columns types
        rowHeaders=TRUE,
        colHeaders=TRUE,

        autoColumnSize=TRUE,
        columnSorting=TRUE,
        manualColumnResize=TRUE,

        width='100%',
        stretchH='all',

        autoWrapRow=TRUE,
        autoWrapCol=TRUE,

        filters=TRUE,
        dropdownMenu=TRUE,

        licenseKey='non-commercial-and-evaluation' # You should enter your commercial license key here.
    )
);