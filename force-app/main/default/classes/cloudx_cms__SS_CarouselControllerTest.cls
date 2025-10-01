/**
 * Test class for SS_CarouselController
*/
@isTest
public with sharing class SS_CarouselControllerTest {
	// Sample Carousel Names for testing.
	static List<String> testCarouselNames = new List<String> {'Carousel1', 'Carousel2'};

	// Setup Test data for testing.
	@testSetup static void setup() {
		// Create common test accounts
		List<SS_Carousel__c> testCarouselList = new List<SS_Carousel__c>();
		for (Integer i = 0; i < 1; i++) {
			testCarouselList.add(new SS_Carousel__c(Name__c = testCarouselNames[i]));
		}
		insert testCarouselList;

		List<SS_Carousel_Slide__c> testCarouselSlideList = new List<SS_Carousel_Slide__c>();

		// Create Image Carousel Slide
		String imageRecordTypeId = Schema.SObjectType.SS_Carousel_Slide__c.getRecordTypeInfosByName().get('Image').getRecordTypeId();
		String videoRecordTypeId = Schema.SObjectType.SS_Carousel_Slide__c.getRecordTypeInfosByName().get('Video').getRecordTypeId();

		testCarouselSlideList.add(new SS_Carousel_Slide__c( RecordTypeId = imageRecordTypeId, Carousel__c = testCarouselList[0].Id, Image_URL__c = 'https://SampleImageUrl'));
		testCarouselSlideList.add(new SS_Carousel_Slide__c(RecordTypeId = videoRecordTypeId, Carousel__c = testCarouselList[0].Id, Video_Embed_URL__c = 'https://SampleVideoUrl'));

		insert testCarouselSlideList;
	}


	// Test Method for SS_CarouselController.getSlidesByCarouselName
	static testMethod void  getSlidesByCarouselName() {
		List<SS_CarouselSlideDTO> slidesList = SS_CarouselController.getSlidesByCarouselName(testCarouselNames[0]);

		// Assert if no records returned.
		System.assertNotEquals(null, slidesList);
		System.assertNotEquals(0, slidesList.size());

		// Assert if no. of records not equals 2 - as two records were inserted in the test setup.
		System.assertEquals(2, slidesList.size());

		// Check image and video fields in appropriate record type.
		for (SS_CarouselSlideDTO slide : slidesList) {
			if (slide.type == 'image') {
				System.assertNotEquals(null, slide.bannerImageUrl);
			} else if (slide.type == 'video') {
				System.assertNotEquals(null, slide.videoUrl);
			}
		}
	}
}