import { LightningElement, api, wire } from 'lwc';
import getLatestRemarks from '@salesforce/apex/GreetingCallController.getLatestRemarks';

export default class GreetingRemarksTable extends LightningElement {
    @api recordId;
    parsedData = [];
    columns = [
        { label: 'Field Name', fieldName: 'fieldName' },
        { label: 'Status', fieldName: 'status' },
        { label: 'Value', fieldName: 'value' },
        { label: 'Comments', fieldName: 'comments' }
    ];

    @wire(getLatestRemarks, { recordId: '$recordId' })
    wiredRemarks({ error, data }) {
        if (data) {
            this.parseString(data);
        } else if (error) {
            console.error('Error fetching remarks', error);
        }
    }

    parseString(rawString) {
        // 1. Split by the " % ," delimiter to get individual rows
        const rows = rawString.split('%  ,');
        
        this.parsedData = rows.map((row, index) => {
            if (!row.trim()) return null;

            // Split Key from the rest: "ProjectName: Yes~Runwal Bliss~"
            const [keyPart, valuePart , label] = row.split(': ');
            
            // Split the rest by "~"
            const details = valuePart ? valuePart.split('~') : [];

            return {
                id: index,
                fieldName: label? label.replace('%', '').trim(): keyPart.trim(),
                status: details[0] || '',
                value: details[1] || '',
                comments: details[2] || ''
            };
        }).filter(item => item !== null);
    }
}