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

        /** Timer to not send too much changes to RPGM */
        this._debouncer = null;

        /** JS binding */
        this.sendChange = this.sendChange.bind(this);
        this.onInitialized = this.onInitialized.bind(this);
        this.onValueChange = this.onValueChange.bind(this);
        this.onSelectionChange = this.onSelectionChange.bind(this);

        // Create table
        const element = document.getElementById(`handsontable-${options.id}`);
        element.style.height = `${options.height}px`;
        console.log(element);
        console.log(options.data);
        this._table = new Handsontable(element, options.data);

        // Detect zoom change and drag
        this._table.addHook('afterInit', this.onInitialized);

        this._table.addHook('afterCreateRow', this.onValueChange);
        this._table.addHook('afterCreateCol', this.onValueChange);
        this._table.addHook('afterChange', this.onValueChange);
        
        this._table.addHook('afterDeselect', this.onSelectionChange);
        this._table.addHook('afterDrawSelection', this.onSelectionChange);
    }

    getId(){
        return this._id;
    }

    onInitialized(){

    }

    /**
     * This function is called when the user changes the zoom or drag the map.
     * It debounces the call to R by setting a timer.
     */
    onValueChange(){
        if(this._debouncer !== null){
            clearTimeout(this._debouncer);
        }
        this._debouncer = setTimeout(this.sendChange, 200); // 200ms
    }

    onSelectionChange(){

    }

    /**
     * Actually send the map state to R.
     */
    sendChange(){
        RPGM.sendMessage('r', 'leaflet/onDidChangeView', {
            id: this._id,
            northLat: this._map.getBounds().getNorth(),
            eastLng: this._map.getBounds().getEast(),
            southLat: this._map.getBounds().getSouth(),
            westLng: this._map.getBounds().getWest(),
            zoomLevel: this._map.getZoom()
        });
    }
}