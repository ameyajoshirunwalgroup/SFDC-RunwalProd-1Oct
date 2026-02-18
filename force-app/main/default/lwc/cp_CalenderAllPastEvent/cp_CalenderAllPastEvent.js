import { LightningElement,api,wire,track } from 'lwc';
import getAllPastCampaigns from '@salesforce/apex/Controller_CampaignCPPortal.getAllPastCampaigns';
import { NavigationMixin } from 'lightning/navigation';

export default class Cp_CalenderAllPastEvent extends NavigationMixin(LightningElement) {


    @track campaigns;
    filteredcampaigns=[];
    @track numberOfEvents;
    headerTitle;
    @track isStrategicPartner;
    connectedCallback() {
    //this.sfdcBaseURL = window.location.origin;
    let text = window.location.href;
    this.isStrategicPartner = text.includes("/channelpartner/");
    console.log('Checking Hub Type---'+  this.isStrategicPartner+' '+ window.location.href);
    }
    @wire(getAllPastCampaigns,{isStrategicPartner:'$isStrategicPartner'}) 
    wiredCampaigns({error,data}){
        if(data){
            this.campaigns=JSON.parse(JSON.stringify(data));
            let currentPageUrl = window.location.href;
          
                this.campaigns=JSON.parse(JSON.stringify(data));
          
            this.numberOfEvents=this.campaigns.length;
            console.log('data------'+JSON.stringify(data));
            this.headerTitle="CP Past Events ("+this.numberOfEvents+")";
           /* for(var i=0;i<this.campaigns.length;i++){
                if(this.campaigns[i].Type==SmartTrainingCampaign){
                    this.campaigns[i].imgType=CalenderSmartSeriesUrl
                }
                else if(this.campaigns[i].Type==BestPracticesCampaign){
                    this.campaigns[i].imgType=CalenderBestPracticesUrl;
                }
                else if(this.campaigns[i].Type==HubConferenceCampaign){
                    this.campaigns[i].imgType=CalenderConference;
                }*/
            }
        }
        
     navigateToCampainDetailsLWC(event) {
        console.log('event.currentTarget '+event.currentTarget.id.split('-')[0]);
        console.log("***************Clicked*************");
        //window.open("http://google.com");
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