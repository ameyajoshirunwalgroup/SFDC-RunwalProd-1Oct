import { LightningElement } from 'lwc';
import percentfixed from './percentFixed.html';
import LightningDatatable from 'lightning/datatable';


export default class FileUploadDataTable extends LightningDatatable   {
    static customTypes = {
        percentfixed : {
            template : percentfixed,
        } 
    };
}