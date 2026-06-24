public class ParkingAllocationService {
    public class ParkingValidationException extends Exception {}
	public class ParkingQuantity {
		public Integer requestedEarmarkedQty;
		public Integer requestedAdditionalQty;

		public ParkingQuantity(Decimal earmarkedDec, Decimal additionalDec) {
			requestedEarmarkedQty  = earmarkedDec  == null ? 0 : (Integer)earmarkedDec;
			requestedAdditionalQty = additionalDec == null ? 0 : (Integer)additionalDec;

		}
	}
	// Holds all prepared data required for validation & sync
	public class ParkingContext {

		// Requested quantities from quotation
		public Map<String, ParkingQuantity> requestedParkingByType =
			new Map<String, ParkingQuantity>();

		// Earmarked parkings linked to unit (grouped by type)
		public Map<String, List<Car_Parking_Charge__c>> unitEarmarkedParkingByType =
			new Map<String, List<Car_Parking_Charge__c>>();

		// Available additional parkings at project level (grouped by type)
		public Map<String, List<Car_Parking_Charge__c>> projectAvailableParkingByType =
			new Map<String, List<Car_Parking_Charge__c>>();
	}

	// Maps Parking Type → Quotation fields
	public class ParkingFieldConfig {
		public String parkingType;
		public SObjectField earmarkedField;
		public SObjectField additionalField;

		public ParkingFieldConfig(
			String parkingType,
			SObjectField earmarkedField,
			SObjectField additionalField
		){
			this.parkingType = parkingType;
			this.earmarkedField = earmarkedField;
			this.additionalField = additionalField;
		}
	}
	public List<ParkingFieldConfig> getParkingConfigs() {
		return new List<ParkingFieldConfig>{
			new ParkingFieldConfig(
				'Single Covered',
				Quotation__c.Single_car_park_earmarked__c,
				Quotation__c.Single_car_park_additional__c
			//)
			),

			new ParkingFieldConfig(
				'Tandem Covered',
				Quotation__c.Tandem_car_park_earmarked__c,
				Quotation__c.Tandem_car_park_additional__c
			),

			new ParkingFieldConfig(
				'Single Open',
				Quotation__c.Single_Open_Earmarked__c,
				Quotation__c.Single_Open_Additional__c
			),

			new ParkingFieldConfig(
				'Tandem Open',
				Quotation__c.Tandem_Open_Earmarked__c,
				Quotation__c.Tandem_Open_Additional__c
			),

			new ParkingFieldConfig(
				'Covered Stack',
				Quotation__c.Covered_Stack_Earmarked__c,
				Quotation__c.Covered_Stack_Additional__c
			),
		// Single_car_park_earmarked__c,Single_car_park_additional__c,Tandem_car_park_earmarked__c,Tandem_car_park_additional__c,Single_Open_Earmarked__c,Single_Open_Additional__c,
		// Tandem_Open_Earmarked__c,Tandem_Open_Additional__c,Covered_Stack_Earmarked__c,Covered_Stack_Additional__c,Stilt_Earmarked__c,Stack_Additional__c,MLCP_Earmarked__c,
		// MLCP_Additional__c,Basement_Earmarked__c,Basement_Additional__c,Podium_Earmarked__c,Podium__c,Puzzle_Car_Park_Earmarked__c,Puzzle_Car_Park__c
			new ParkingFieldConfig(
				'Stilt',
				Quotation__c.Stilt_Earmarked__c,
				Quotation__c.Stack_Additional__c
			),

			new ParkingFieldConfig(
				'MLCP',
				Quotation__c.MLCP_Earmarked__c,
				Quotation__c.MLCP_Additional__c
			),

			new ParkingFieldConfig(
				'Basement',
				Quotation__c.Basement_Earmarked__c,
				Quotation__c.Basement_Additional__c
			),

			new ParkingFieldConfig(
				'Podium',
				Quotation__c.Podium_Earmarked__c,
				Quotation__c.Podium__c
			),

			new ParkingFieldConfig(
				'Puzzle Car Park',
				Quotation__c.Puzzle_Car_Park_Earmarked__c,
				Quotation__c.Puzzle_Car_Park__c
			),

			new ParkingFieldConfig(
				'Stack Car Park',
				Quotation__c.Stack_Earmarked__c,
				Quotation__c.Stack_Additional_1__c
			)

			// 👉 FUTURE: just add one line here
		};
	}
 public Map<String, ParkingQuantity> buildRequestedParkingMap(
        Quotation__c quotation
    ){

        Map<String, ParkingQuantity> requestedMap =
            new Map<String, ParkingQuantity>();

        for(ParkingFieldConfig config : getParkingConfigs()){

            Decimal earmarkedQty =
                (Decimal) quotation.get(config.earmarkedField);

            Decimal additionalQty =
                (Decimal) quotation.get(config.additionalField);

            if(earmarkedQty != null || additionalQty != null){

                requestedMap.put(
                    config.parkingType,
                    new ParkingQuantity(earmarkedQty, additionalQty)
                );
            }
        }

        return requestedMap;
    }

    // ============================================================
    // Prepare Parking Context
    // ============================================================
    public ParkingContext prepareParkingContext(
        Quotation__c quotation,
        Id unitId,
        Id projectId
    ){

        ParkingContext context = new ParkingContext();

        context.requestedParkingByType =
            buildRequestedParkingMap(quotation);

        if(context.requestedParkingByType.isEmpty()){
            return context;
        }

        Set<String> parkingTypes =
            context.requestedParkingByType.keySet();

        context.unitEarmarkedParkingByType =
            fetchUnitEarmarkedParking(unitId, parkingTypes);

        context.projectAvailableParkingByType =
            fetchProjectAvailableParking(projectId, parkingTypes);

        return context;
    }

    // ============================================================
    // Fetch Unit Earmarked Parking
    // ============================================================
    public Map<String, List<Car_Parking_Charge__c>> fetchUnitEarmarkedParking(
        Id unitId,
        Set<String> parkingTypes
    ){

        Map<String, List<Car_Parking_Charge__c>> result =
            new Map<String, List<Car_Parking_Charge__c>>();

        for(Car_Parking_Charge__c parking : [

            SELECT Id, Parking__c
            FROM Car_Parking_Charge__c
            WHERE Parking__c IN :parkingTypes
            AND Category__c = 'Earmarked'
            AND Project_Unit__c = :unitId

        ]){

            if(!result.containsKey(parking.Parking__c)){
                result.put(parking.Parking__c,
                    new List<Car_Parking_Charge__c>());
            }

            result.get(parking.Parking__c).add(parking);
        }

        return result;
    }

    // ============================================================
    // Fetch Project Additional Parking
    // ============================================================
    public Map<String, List<Car_Parking_Charge__c>> fetchProjectAvailableParking(
        Id projectId,
        Set<String> parkingTypes
    ){

        Map<String, List<Car_Parking_Charge__c>> result =
            new Map<String, List<Car_Parking_Charge__c>>();

        for(Car_Parking_Charge__c parking : [

            SELECT Id, Parking__c
            FROM Car_Parking_Charge__c
            WHERE Parking__c IN :parkingTypes
            AND Status__c = 'Vacant'
            AND Category__c = 'Additional'
            AND Project_Unit__c = null
            AND Project__c = :projectId

        ]){

            if(!result.containsKey(parking.Parking__c)){
                result.put(parking.Parking__c,
                    new List<Car_Parking_Charge__c>());
            }

            result.get(parking.Parking__c).add(parking);
        }

        return result;
    }

    // ============================================================
    // Validate Parking Availability
    // ============================================================
    public Boolean validateCarParkingAvailability(ParkingContext context){
        List<String> errors = new List<String>();
        Boolean hasError = false;

        for(String parkingType : context.requestedParkingByType.keySet()){

            ParkingQuantity qty =
                context.requestedParkingByType.get(parkingType);

            Integer availableUnitEarmarked =
                context.unitEarmarkedParkingByType.containsKey(parkingType)
                ? context.unitEarmarkedParkingByType.get(parkingType).size()
                : 0;

            if(qty.requestedEarmarkedQty > availableUnitEarmarked){

                String msg =
                    'Only ' + availableUnitEarmarked +
                    ' earmarked ' + parkingType +
                    ' parking(s) available for this unit.';

                if(ApexPages.currentPage() != null){
                    ApexPages.addMessage(
                        new ApexPages.Message(ApexPages.Severity.ERROR, msg)
                    );
                }
                else{
                    //throw new ParkingValidationException(msg);
                    errors.add(msg);
                }

                hasError = true;
            }

            Integer availableProjectAdditional =
                context.projectAvailableParkingByType.containsKey(parkingType)
                ? context.projectAvailableParkingByType.get(parkingType).size()
                : 0;

            if(qty.requestedAdditionalQty > availableProjectAdditional){

                String msg =
                    'Only ' + availableProjectAdditional +
                    ' additional ' + parkingType +
                    ' parking(s) available.';

                    // If called from Visualforce
                    if(ApexPages.currentPage() != null){
                        ApexPages.addMessage(
                            new ApexPages.Message(ApexPages.Severity.ERROR, msg)
                        );
                    }
                    // If called from trigger / backend
                    else{
                        //throw new ParkingValidationException(msg);
                        errors.add(msg);
                    }


                hasError = true;
            }
        }
        if(!errors.isEmpty() && ApexPages.currentPage() == null){

            String finalMessage = '';

            for(String err : errors){
                finalMessage += err + '\n'; // 🔥 new line instead of |
            }

            throw new ParkingValidationException(finalMessage);
        }

        return hasError;
    }

    // ============================================================
    // Sync Parking After Booking
    // ============================================================
    public void syncCarParkingAfterBooking(
        Id bookingId,
        ParkingContext context
    ){

        List<Car_Parking_Charge__c> updates =
            new List<Car_Parking_Charge__c>();

        for(String parkingType : context.requestedParkingByType.keySet()){

            ParkingQuantity qty =
                context.requestedParkingByType.get(parkingType);

            List<Car_Parking_Charge__c> earmarked =
                context.unitEarmarkedParkingByType.containsKey(parkingType)
                ? context.unitEarmarkedParkingByType.get(parkingType)
                : new List<Car_Parking_Charge__c>();

            List<Car_Parking_Charge__c> additional =
                context.projectAvailableParkingByType.containsKey(parkingType)
                ? context.projectAvailableParkingByType.get(parkingType)
                : new List<Car_Parking_Charge__c>();

            for(Integer i=0;i<qty.requestedEarmarkedQty && i<earmarked.size();i++){

                earmarked[i].Status__c = 'Booked';
                earmarked[i].Booking__c = bookingId;

                updates.add(earmarked[i]);
            }

            for(Integer i=0;i<qty.requestedAdditionalQty && i<additional.size();i++){

                additional[i].Status__c = 'Booked';
                additional[i].Booking__c = bookingId;

                updates.add(additional[i]);
            }
        }

        if(!updates.isEmpty()){
            update updates;
        }
    }

    public static void allocateParkingFromQuotation(
    Quotation__c quotation,
    Id bookingId
    ){

        ParkingAllocationService service =
            new ParkingAllocationService();

        ParkingContext context =
            service.prepareParkingContext(
                quotation,
                quotation.Project_Unit__c,
                quotation.Project__c
            );

        Boolean hasError =
            service.validateCarParkingAvailability(context);

        if(hasError){
            return;
        }


        service.syncCarParkingAfterBooking(
            bookingId,
            context
        );
    }
}