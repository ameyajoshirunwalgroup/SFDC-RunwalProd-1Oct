/**
 *  Data Transfer Object That represents Carousel Slide.
*/
public with sharing class SS_CarouselSlideDTO {
	public SS_CarouselSlideDTO(SS_Carousel_Slide__c carouselSlide) {
		this.id = carouselSlide.Id;
		this.type = carouselSlide.RecordType.DeveloperName;
		this.title = carouselSlide.Title__c;
		this.bannerImageUrl = carouselSlide.Image_URL__c;
		this.videoUrl = carouselSlide.Video_Embed_URL__c;
		this.mp4VideoUrl = carouselSlide.Raw_MP4_Video_URL__c;
		this.oggVideoUrl = carouselSlide.Raw_OGG_Video_URL__c;
		this.webmVideoUrl = carouselSlide.Raw_WEBM_Video_URL__c;
		this.buttonLabel = carouselSlide.Button_Label__c;
		this.buttonUrl = carouselSlide.Button_URL__c;
		this.buttonVariant = carouselSlide.Button_Variant__c;
		this.textAlign = carouselSlide.Text_Alignment__c;
		this.textPosition = carouselSlide.Text_Position__c;
		this.description = carouselSlide.Description__c;
		this.descriptionColor = carouselSlide.Description_Text_Color__c;
		this.descriptionSize = carouselSlide.Description_Size__c;
		this.titleSize = carouselSlide.Title_Text_Size__c;
		this.titleColor = carouselSlide.Title_Text_Color__c;
		this.textOverlayBackground = carouselSlide.Text_Overlay_Background__c;
		this.height = carouselSlide.Height__c;
		this.autoplay = carouselSlide.Autoplay__c;
		this.loopVideo = carouselSlide.Loop_Video__c;
		this.showVideoControls = carouselSlide.Show_Video_Controls__c;

		this.textHeight = carouselSlide.Text_Height__c;
	}

	@AuraEnabled
	public String id { get;  set; }
	@AuraEnabled
	public String type { get;  set; }
	@AuraEnabled
	public String title { get;  set; }
	@AuraEnabled
	public String bannerImageUrl { get;  set; }
	@AuraEnabled
	public String buttonLabel { get;  set; }
	@AuraEnabled
	public String buttonUrl { get;  set; }
	@AuraEnabled
	public String videoUrl { get;  set; }
	@AuraEnabled
	public String mp4VideoUrl { get;  set; }
	@AuraEnabled
	public String oggVideoUrl { get;  set; }
	@AuraEnabled
	public String webmVideoUrl { get;  set; }
	@AuraEnabled
	public String textAlign { get;  set; }
	@AuraEnabled
	public String textPosition { get;  set; }
		@AuraEnabled
	public Double textHeight { get;  set; }

	@AuraEnabled
	public String buttonVariant { get;  set; }
	@AuraEnabled
	public String description { get;  set; }
	@AuraEnabled
	public String descriptionColor { get;  set; }
	@AuraEnabled
	public String descriptionSize { get;  set; }
	@AuraEnabled
	public Double height { get;  set; }

	@AuraEnabled
	public Boolean autoplay { get;  set; }
	@AuraEnabled
	public Boolean loopVideo { get;  set; }
	@AuraEnabled
	public Boolean showVideoControls { get;  set; }

	@AuraEnabled
	public String titleSize { get;  set; }
	@AuraEnabled
	public String titleColor { get;  set; }
	@AuraEnabled
	public String textOverlayBackground { get;  set; }

}