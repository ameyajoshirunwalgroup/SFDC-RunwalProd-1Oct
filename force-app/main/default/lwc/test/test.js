import { LightningElement } from 'lwc';
import html2pdfResource from '@salesforce/resourceUrl/html2pdf';
import { loadScript } from 'lightning/platformResourceLoader';
export default class Test extends LightningElement {
    scriptLoaded = false;

    renderedCallback() {

        if (this.scriptLoaded) return;

        this.scriptLoaded = true;

        loadScript(this, html2pdfResource + '/html2pdf.bundle.min.js')
            .then(() => {
                console.log('html2pdf loaded successfully');
                console.log('html2pdf:', window.html2pdf);
            })
            .catch(error => {
                console.error('Script load error', error);
            });
    }

    generatePdf() {

        console.log('Button clicked');

        window.html2pdf().from('<h1>Hello PDF</h1>').save();
    
        /*const element = this.template.querySelector('.pdf-container');
    
        if (!element) {
            console.error('Element not found');
            return;
        }
    
        const html = element.outerHTML;
    
        const options = {
            margin: 10,
            filename: 'MyPDF.pdf',
            html2canvas: { scale: 2 },
            jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
        };
    
        window.html2pdf()
            .set(options)
            .from(html)
            .save();*/
    }
}