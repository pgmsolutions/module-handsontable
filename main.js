/**
 * Manage all the tables in the app.
 */
window.HandsontableManager = new class {
    constructor(){
        this._currentStepCache = null;
        this._tables = [];
    }

    /**
     * Initialize the table manager by setting hook on the RPGM app.
     */
    initialize(){
        // Send R the current step
        RPGM.on('didEnterStep', (stepId)=>{
            this._currentStepCache = stepId;
            RPGM.sendMessage('r', 'handsontable/onDidEnterStep', {stepId: this._currentStepCache});
        });

        // When receiving a message
        RPGM.on('didReceiveMessage', (message, data)=>{
            if(message === 'handsontable/enterStep' && this._currentStepCache !== null){
                RPGM.sendMessage('r', 'handsontable/onDidEnterStep', {stepId: this._currentStepCache});
                return;
            }
            if(message === 'handsontable/initialize'){
                this._tables.push(new HandsontableInstance({
                    id: data.tableId,
                    height: data.height,
                    data: data.data
                }));
                return;
            }

            // All next messages requires a tableId
            const tableInstance = this.getTable(data.tableId);
            if(tableInstance === undefined){
                return;
            }

            // Packets
            if(message === 'handsontable/update'){
                tableInstance.update(data.data);
            }
        });

        // Destroy all instances when leaving current step
        RPGM.on('willLeaveStep', (stepId)=>{
            this._tables.forEach(t => t.destroy());
            this._tables = [];
        });
    }

    /**
     * Return a table by its id or undefined if not found.
     */
    getTable(tableId){
        return this._tables.find(m => m.getId() === tableId);
    }
}
HandsontableManager.initialize();

/**
 * This class manages a handsontable instance.
 */
window.HandsontableInstance = class {
    constructor(options){
        this._id = options.id;

        /** Prevent recursive updates */
        this._skipNextChange = false;

        /** Timer to not send too much changes to RPGM */
        this._debouncer = null;
        this._debouncerData = null;

        /** JS binding */
        this.sendValue = this.sendValue.bind(this);
        this.sendSelection = this.sendSelection.bind(this);
        this.onInitialized = this.onInitialized.bind(this);
        this.onValueChange = this.onValueChange.bind(this);
        this.onSelectionChange = this.onSelectionChange.bind(this);

        // Create table
        const element = document.getElementById(`handsontable-${options.id}`);
        element.style.height = `${options.height}px`;
        this._table = new Handsontable(element, options.data);

        // Detect zoom change and drag
        this._table.addHook('afterInit', this.onInitialized);

        this._table.addHook('afterCreateRow', this.onValueChange);
        this._table.addHook('afterCreateCol', this.onValueChange);
        this._table.addHook('afterChange', this.onValueChange);
        
        this._table.addHook('afterSelection', this.onSelectionChange);
        this._table.addHook('afterDeselect', this.onSelectionChange);

        // State
        this._active = true;
    }

    getId(){
        return this._id;
    }

    onInitialized(){
        RPGM.sendMessage('r', 'handsontable/onDidLoad', {
            id: this._id,
        });
    }

    onValueChange(){
        if(this._skipNextChange){
            this._skipNextChange = false;
            return;
        }
        if(this._debouncer2 !== null){
            clearTimeout(this._debouncer2);
        }
        this._debouncer2 = setTimeout(this.sendValue, 200); // 200ms
    }
    sendValue(){
        if(!this._active){
            return;
        }

        // Transform the array of array to an R data-frame ready object by transposing
        const content = this._table.getData();
        const contentObject = {};
        if(content.length > 0){
            const nrows = content.length;
            for (let c = 0; c < content[0].length; c++) {
                contentObject[`c${c}`] = Array(nrows);
            }
            for(let r = 0; r < content.length; r++) {
                for (let c = 0; c < content[r].length; c++) {
                    if(content[r][c] == null){
                        contentObject[`c${c}`][r] = ''
                    } else {
                        contentObject[`c${c}`][r] = content[r][c];
                    }
                }
            }
        }
        
        // Row headers
        const colsHeaders = this._table.getColHeader();
        const rowsHeaders = this._table.getRowHeader();

        // Send message
        RPGM.sendMessage('r', 'handsontable/onDidChangeValue', {
            id: this._id,
            cols: colsHeaders.every(h => h === false) ? [] : colsHeaders,
            rows: rowsHeaders.every(h => h === false) ? [] : rowsHeaders,
            value: contentObject
        }, {
            rArrayType: 'vector'
        });
    }

    onSelectionChange(row = null, column = null, row2 = null, column2 = null){
        if(this._debouncer !== null){
            clearTimeout(this._debouncer);
        }
        this._debouncer = setTimeout(this.sendSelection, 200); // 200ms
    }
    sendSelection(){
        if(!this._active){
            return;
        }

        RPGM.sendMessage('r', 'handsontable/onDidChangeSelection', {
            id: this._id,
            selection: this._table.getSelected()
        });
    }

    update(settings){
        if(!this._active){
            return;
        }
        this._skipNextChange = true;
        this._table.updateSettings(settings);
    }

    destroy(){
        if(!this._active){
            return;
        }
        this._active = false;
        this._table.destroy();
    }
}