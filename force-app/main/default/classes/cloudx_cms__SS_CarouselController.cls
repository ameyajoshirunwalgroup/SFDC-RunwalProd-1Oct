/**
 * Carousel Service class that provides carousel data to Lightning components. Used by Carousel Lightning component.
*/
public with sharing class SS_CarouselController {

	/**
	 * Returns list of Carousel Slides
	 *
	 * This method queries list of carousel slides based on custom object.
	 *
	 * @param  carouselName  Name of carousel in SS_Carousel_Slide__c object.
	 * @return list of carousel slides for a given Carousel Name.
	 */
	@AuraEnabled
	public static List<SS_CarouselSlideDTO> getSlidesByCarouselName(String carouselName) {

		String[] carouselSlideFields = new String [] {'Id', 'RecordType.DeveloperName', 'Name', 'Button_Label__c', 'Button_URL__c', 'Button_Variant__c',
		        'Description__c', 'Description_Text_Color__c', 'Image_URL__c',
		        'Text_Alignment__c', 'Text_Overlay_Background__c', 'Text_Position__c',
		        'Title__c', 'Title_Text_Color__c', 'Title_Text_Size__c', 'Video_Embed_URL__c',
		        'Raw_MP4_Video_URL__c', 'Raw_WEBM_Video_URL__c','Raw_OGG_Video_URL__c',
		        'Autoplay__c','Loop_Video__c', 'Show_Video_Controls__c',
		        'Description_Size__c','Height__c','Text_Height__c'
		                                             };


		// Check FLS for the fields being queried.
		Map<String, Schema.SObjectField> m = Schema.SObjectType.SS_Carousel_Slide__c.fields.getMap();

		for (String fieldToCheck : carouselSlideFields) {

			// Check if the user has access to view field
			if (m.get(fieldToCheck) != null && !m.get(fieldToCheck).getDescribe().isAccessible()) {

				// Pass error to client
				throw new System.NoAccessException();

				return null;
			}
		}


		List<SS_Carousel_Slide__c> carouselslideList = [SELECT Id, RecordType.DeveloperName, Name, Button_Label__c, Button_URL__c, Button_Variant__c,
		                           Description__c, Description_Text_Color__c, Image_URL__c,
		                           Text_Alignment__c, Text_Overlay_Background__c, Text_Position__c,
		                           Title__c, Title_Text_Color__c, Title_Text_Size__c, Video_Embed_URL__c,
		                           Raw_MP4_Video_URL__c, Raw_WEBM_Video_URL__c,Raw_OGG_Video_URL__c,
		                           Autoplay__c,Loop_Video__c, Show_Video_Controls__c,
		                           Description_Size__c, Height__c,Text_Height__c
		                           FROM SS_Carousel_Slide__c
		                           Where Carousel__r.Name = :carouselName OR Carousel__r.Name__c = :carouselName
		                                   ORDER BY Slide_Order__c ASC];
		List<SS_CarouselSlideDTO> slideList = new List<SS_CarouselSlideDTO>();
		if (carouselslideList != null && carouselslideList.size() > 0) {
			for (SS_Carousel_Slide__c slide : carouselslideList) {
				slideList.add(new SS_CarouselSlideDTO(slide));
			}
		}
		return slideList;
	}
}