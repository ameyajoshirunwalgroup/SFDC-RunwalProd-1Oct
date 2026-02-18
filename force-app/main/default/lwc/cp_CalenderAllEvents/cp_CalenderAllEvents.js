import { LightningElement,api,wire,track } from 'lwc';
import getAllCampaigns from '@salesforce/apex/Controller_CampaignCPPortal.getAllCampaigns';
import { NavigationMixin } from 'lightning/navigation';

//import SmartTrainingCampaign from '@salesforce/label/c.SmartTrainingCampaign';
import CPMeetsCampaign from '@salesforce/label/c.CPMeetsCampaign';
//import HubConferenceCampaign from '@salesforce/label/c.HubConferenceCampaign';

//import CalenderSmartSeriesUrl from '@salesforce/resourceUrl/CalenderSmartSeries';
import CalenderBestPracticesUrl from '@salesforce/resourceUrl/CalenderBestPracticesWebinar';
//import CalenderConference from '@salesforce/resourceUrl/CalenderConference';

export default class Cp_CalenderAllEvents extends  NavigationMixin(LightningElement) {
    
    @track campaigns;
    filteredcampaigns=[];
    @track numberOfEvents;
    headerTitle;

    @wire(getAllCampaigns) 
    wiredCampaigns({error,data}){
        if(data){
            let currentPageUrl = window.location.href;
            let isStrategicPartner = currentPageUrl.includes("/channelpartner/");
            //this.campaigns=JSON.parse(JSON.stringify(data));
            if(isStrategicPartner){
                this.campaigns=JSON.parse(JSON.stringify(data));
                console.log('Campaigns>>>>', this.campaigns);
                /*for(var i=0;i<this.campaigns.length;i++){
                    if(this.campaigns[i].Type__c==CPMeetsCampaign){
                        this.filteredcampaigns.push(this.campaigns[i]);
                    }
                }
                this.campaigns=this.filteredcampaigns;
                console.log('this.filteredcampaigns>>>', this.filteredcampaigns);*/
            }
            else{
                this.campaigns=JSON.parse(JSON.stringify(data));
            }
            //this.campaigns=JSON.parse(JSON.stringify(data));
            this.numberOfEvents=this.campaigns.length;
            console.log('data------'+JSON.stringify(data));
            console.log('Count of events>>', this.numberOfEvents);
            this.headerTitle="CP Events ("+this.numberOfEvents+")";
            /*for(var i=0;i<this.campaigns.length;i++){
               if(this.campaigns[i].Type__c==CPMeetsCampaign){
                    this.campaigns[i].imgType=CalenderBestPracticesUrl;
                }
            }*/
        }

    }
     navigateToCampainDetailsLWC(event) {
        console.log('event.currentTarget '+event.currentTarget.id.split('-')[0]);
        console.log("***************Clicked*************");
        let userId = '';
        let campaignId = event.currentTarget.id.split('-')[0];
        let newUrl = window.location.origin +'/s/cp-event-detail-page'+'?'+'campaignId'+'='+campaignId;
        let currentPageUrl = window.location.href;
        let isStrategicPartner = currentPageUrl.includes("/channelpartner/");
        if(isStrategicPartner){
            newUrl = window.location.origin +'/channelpartner/s/cp-event-detail-page'+'?'+'campaignId'+'='+campaignId;
        }else{
            newUrl = window.location.origin +'/s/cp-event-detail-page'+'?'+'campaignId'+'='+campaignId;
        }
        console.log('url------'+newUrl);
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: newUrl
            }
        },
        true // Replaces the current page in your browser history with the URL
        );
    }

}