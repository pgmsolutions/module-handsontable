source(rpgm.pgmFilePath('modules/handsontable/main.R'))

# Initialize the table widget
Handsontable.create(
    'main',
    rpgm.step('main', 'handsontable'),
    'table',
    height = 512,
    data = list(
        data=list(
            list('', 'Tesla', 'Volvo', 'Toyota', 'Ford'),
            list('2019', 10, 11, 12, 13),
            list('2020', 20, 11, 14, 13),
            list('2021', 30, 15, 12, 1)
        ),
        rowHeaders=TRUE,
        colHeaders=TRUE,
        autoWrapRow=TRUE,
        autoWrapCol=TRUE,
        licenseKey='non-commercial-and-evaluation'
    )
)