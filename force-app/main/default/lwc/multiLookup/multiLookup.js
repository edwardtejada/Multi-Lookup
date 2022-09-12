import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import apexSearch from '@salesforce/apex/LookupController.search';

export default class MultiLookup extends LightningElement {
    @api notifyViaAlerts = false;
    
    @track errors = [];
    @track isMultiEntry = false;
    @track initialSelection = [
        {
            id: 'na', 
            sObjectType: 'na', 
            icon: 'standard:lightning_component', 
            title: 'Inital selection', 
            subtitle:'Not a valid record'
        }
    ];

    handleLookupTypeChange(event) {
        this.initialSelection = [];
        this.errors = [];
        this.isMultiEntry = event.target.checked;
    }

    handleSearch(event) {
        apexSearch(event.detail)
            .then(results => {
                this.template.querySelector('c-lookup').setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleSelectionChange() {
        this.errors = [];
    }

    handleSubmit() {
        this.checkForErrors();
        if (this.errors.length === 0) {
            this.notifyUser('Success', 'The form was submitted.', 'success');
        }
    }

    checkForErrors() {
        const selection = this.template.querySelector('c-lookup').getSelection();
        if (selection.length === 0) {
            this.errors = [
                { message: 'You must make a selection before submitting!' },
                { message: 'Please make a selection and try again.' }
            ];
        } else {
            this.errors = [];
        }
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts){
            alert(`${title}\n${message}`);
        } else {
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }
}