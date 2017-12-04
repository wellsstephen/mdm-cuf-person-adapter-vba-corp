##Drafted by Aramis Calderon (email: aramis.calderon@halfaker.com/ phone: 7608055923)##
Feature: Adapt VET360 phone number BIO to Corp PTCPNT_PHONE data table
		As Department of Veterans Affairs Enterprise, I want to convert phone number records in VET360 to 
		VBA Corp phone records schema. 

    Assumptions:
	- International numbers will not be in scope for IOC.
	- Record coming from VET360 is a Veteran.
	- Veteran records wih 2 PARTICIPANT_IDs will be sent to the Error Queue and never populate in the changelog.
	- Any change pushed to Corp by VET360 is already validated as an Living Veteran.
	- Adapter will be able to query existing records in Corp
	- Contact information change pushed out to Corp that matches records will be End-Dated even if the 
		core fields (e.g. area number, phone number, extension) are identical thus updating the provenance fields (i.e. the mapped JRN_XX columns)
		
    Field Mappings:
	- New PTCPNT_PHONE record is created with VET360 effectiveStartDate.
	- Existing Corp phone record's END_DT is set to VET360 effectiveStartDate.
	- Work phone number from VET360 maps to PHONE_TYPE_NM Daytime.
	- Home phone number from VET360 maps to PHONE_TYPE_NM Nighttime.
	- Mobile phone number from VET360 maps to PHONE_TYPE_NM Cellular.
	- VET360 phoneNumber populates Corp PHONE_NBR field.
	- VET360 phoneType populates Corp PHONE_TYPE_NM field.
	- VET360 areaCode populates Corp AREA_NBR field.
	- VET360 phoneNumberExt populates Corp EXTNSN_NBR field.
	- VET360 effectiveStartDate populates Corp EFCTV_DT field.
	- VET360 effectiveEndDate populates Corp END_DT field.
	- VET360 sourceDate populates Corp JRN_DT field.
	- VET360 orginatingSourceSys populates Corp JRN_OBJ_ID field.
	- VET360 sourceSystem populates Corp JRN_EXTNL_APPLCN_NM field.
    - VET360 sourceSysUser populates Corp JRN_USER_ID field.
	- Corp JRN_LCTN_ID value will be derived from service.
	- Corp JRN_STATUS_TYPE_CD value will be derived from type of transaction.
	
	Background: Veteran phone record from VET360 adapted to Corp PTCPNT_PHONE table.
		Given VET360 BIO Schema for phone
			| Attribute Name                    | Coded Value            | Mandatory/Optional | Type            | Length | Standard | common/core | IOC |
			| International Indicator           | internationalInd       | Mandatory          | Boolean         |        | none     |             | Y   |
			| Country Code                      | countryCode            | Optional           | Enumerated List |        | E.164    |             | Y   |
			| Area Code                         | areaCode               | Optional           | String          | 3      | none     |             | Y   |
			| Phone Number                      | phoneNumber            | Mandatory          | String          | 14     | none     |             | Y   |
			| Phone Number Extension            | phoneNumberExt         | Optional           | String          | 10     | none     |             | Y   |
			| Phone Type                        | phoneType              | Mandatory          | Enumerated List |        | none     |             | Y   |
			| Effective Start Date              | effectiveStartDate     | Optional           | Date            |        | ISO 8601 |             | Y   |
			| Effective End Date                | effectiveEndDate       | Optional           | Date            |        | ISO 8601 |             | Y   |
			| Text Message Capable Indicator    | textMessageCapableInd  | Optional           | Boolean         |        | none     |             | Y   |
			| Text Message Permission Indicator | textMessagePermInd     | Optional           | Boolean         |        | none     |             | Y   |
			| Voice Mail Acceptable Indicator   | voiceMailAcceptableInd | Optional           | Boolean         |        | none     |             | Y   |
			| TTY Indicator                     | ttyInd                 | Optional           | Boolean         |        | none     |             | Y   |
			| Connection Status Code            | connectionStatusCode   | Optional           | Enumerated List |        | none     |             | Y   |
			| Confirmation Date                 | ConfDate               | Optional           | Date            |        | ISO 8601 |             | Y   |
			| Source System                     | sourceSystem           | Optional           | String          | 255    | none     | core        | Y   |
			| Originating Source System         | orginatingSourceSys    | Optional           | String          | 255    | none     | core        | Y   |
			| Source System User                | sourceSysUser          | Optional           | String          | 255    | none     | core        | Y   |
			| Source Date                       | sourceDate             | Mandatory          | Date/Time (GMT) |        | ISO 8601 | core        | Y   |
			| Telephone ID                      | telephoneId            | Optional           | String          |        | none     |             | Y   |
		
		Given VBA Corp Schema for PTCPNT_PHONE
			| Attribute Name							| Coded Value			| Mandatory/Optional		| Type          |	Length |		
			| COMMUNICATION DEVICE AREA NUMBER			| AREA_NBR				| Optional					| NUMBER		|	4	   |					
			| PARTICIPANT PHONE COUNTRY NUMBER			| CNTRY_NBR				| Optional					| NUMBER		|	4	   |
			| PARTICIPANT PHONE EFFECTIVE DATE			| EFCTV_DT				| Mandatory					| DATE			|          |
			| END DATE									| END_DT				| Optional					| DATE			|		   |
			| COMMUNICATION DEVICE EXTENSION NUMBER		| EXTNSN_NBR			| Optional					| VARCHAR2   	|	5	   |
			| FRGN PHONE RFRNC TXT 						| FRGN_PHONE_RFRNC_TXT	| Optional					| VARCHAR2  	|	30     |
			| JOURNAL DATE								| JRN_DT				| Mandatory					| DATE			|		   |
			| JOURNAL EXTERNAL APPLICATION NAME			| JRN_EXTNL_APPLCN_NM	| Optional					| VARCHAR2   	|	50	   |
   			| JOURNAL EXTERNAL KEY TEXT					| JRN_EXTNL_KEY_TXT		| Optional					| VARCHAR2  	|	50     |
			| JOURNAL EXTERNAL USER IDENTIFER			| JRN_EXTNL_USER_ID		| Optional					| VARCHAR2  	|	50     |
			| JOURNAL LOCATION IDENTIFIER				| JRN_LCTN_ID			| Mandatory					| VARCHAR2  	|	4      |
			| JOURNAL OBJECT IDENTIFIER					| JRN_OBJ_ID			| Mandatory					| VARCHAR2      |	32	   |
			| JOURNAL STATUS TYPE CODE					| JRN_STATUS_TYPE_CD	| Mandatory					| VARCHAR2  	|	12	   |
			| JOURNAL USER IDENTIFIER					| JRN_USER_ID			| Mandatory					| VARCHAR2  	|	50     |
			| PARTICIPANT PHONE NUMBER					| PHONE_NBR				| Mandatory					| NUMBER    	|	11     |
			| PARTICIPANT TELEPHONE TYPE NAME			| PHONE_TYPE_NM			| Mandatory					| VARCHAR2   	|	50     |
			| Identifier of PTCPNT						| PTCPNT_ID				| Mandatory					| NUMBER    	|	15     |
		
		Given the system has defined a valid Domestic Phone Number
			| attrbuteName           | value                    |
			| vet360Id               | 1                        |
			| sourceSystem           | VETSGOV                  |
			| orginatingSourceSys    | VET360                   |
			| sourceSysUser          | Janey                    |
			| internationalInd       | false                    |
			| areaCode               | 703                      |
			| phoneNumber            | 6585098                  |
			| phoneType              | WORK                     |
			| phoneNumberExt         | 123456                   |
			| ttyInd                 | True                     |
			| sourceDate             | Today                    |
			| voiceMailAcceptableInd | true                     |
			| textMessageCapableInd  | true                     |
			| textMessagePermInd     | True                     |
			| effectiveStartDate     | Today                    |
				
	Scenario: Drop record if the Phone Type is not to be synchronized with Corp
		Given a valid vet360 person phone BIO received from the CUF changelog
		When phoneType is "<Temporary>" or "<Pager>"
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF

	Scenario: Drop record if the Phone Type is an unexpected value with no mapping Corp
		Given a valid vet360 person phone BIO received from the CUF changelog
		When the changelog BIO phoneType is not "<Work>", "<Home>", "<Fax>", or "<Mobile>"
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF
	
	Scenario: Dropping a Phone Number record that is not Domestic
		Given a valid vet360 person phone BIO received from the CUF changelog
		When the changelog BIO internationalInd is "<TRUE>"
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF 
    
	Scenario: Dropping a Phone Number record that does not have a corralated PARTICIPANT_ID in MVI
		Given a valid vet360 person phone BIO received from the CUF changelog
		When the changelog BIO PARTICIPANT_ID is NULL
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF#Pending Michelle
	
	# blank source system user
    # blank originating source system
	
	Scenario Outline: Accepts record if the Phone Type is to be synchronized with Corp
		Given a valid vet360 person phone BIO received from the CUF changelog
		When the changelog BIO phoneType is "<VET360phoneType>"
		Then the Adapter will convert the Domestic Phone Number to the following Corp DIO with "<phoneType>" and sends "COMPLETED_SUCCESS" response to CUF
			|PHONE_NBR | EFCTV_DT | AREA_NBR | JRN_LCTN_ID      | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_DT |
			|7574155   | Today    | 760	     |	<CorpProvided>	|      Jane  |     I              |    Vets.gov     |        |		VET360   |	Today|
		Examples:
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|
	
	Scenario Outline: Updating one existing record in Corp
		Given the following vet360 person phone BIO received from the CUF changelog 
			| SourceSystem |internationalInd | phoneType         | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
			| VET360		 | False		 |"<VET360phoneType>"   |   	1		 | 703	 	| 6585098	  | 12345		 | False  | Today      | True       		    |  False               | True               | Today            	  | VHAISDFAULKJ   | ADR                |
		When the changelog BIO has PTCPNT_ID equal to a Corp record in PTCPNT_PHONE table
		And the changelog BIO effectiveStartDate is greater than or equal to EFCTV_DT or END_DT is NULL
		And has PHONE_TYPE_NM of "<phoneType>"
		Then the Adapter will populate the END_DT field with the changelog BIO effectiveStartDate value as follows
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_LCTN_ID     |  JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM |JRN_DT |
			| "<phoneType>"	   |6585098   | Today -90    |Today    | 703	  |	<CorpProvided>	|     U               |    wuperson|            |		     	      | Today - 3 | VRCCGORT |
		And commits the following new PTCPNT_PHONE record with "<VET360phoneType>" and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_DT | JRN_LCTN_ID         | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM |  
     		| "<phoneType>"	|6585098    | Today	|	       | 703	   | Today  | 	<CorpProvided>	 |     VET360  |     I              |    ADR     |  12345     |		VET360	     |	
	    Examples:
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|
	
	Scenario Outline: VET360 update when Corp has multiple active phone types
		Given the following vet360 person phone BIOs received from the CUF changelog 
			| SourceSystem |internationalInd | phoneType     | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
			| VET360		 | False		 | <phoneType>   |   	1		 | 703	 	  | 6585098	    | 12345		     | False  | Today      | True       		    |  False                | True               | Today              | VHAISDFAULKJ   | ADR                |
		When the changelog BIO has PTCPNT_ID equal to two Corp records in PTCPNT_PHONE table
		And the effectiveStartDate is greater than or equal to EFCTV_DT or END_DT is NULL
		And has PHONE_TYPE_NM of "<phoneType>"
		Then the Adapter will populate the END_DT fields with changelog BIO effectiveStartDate value as follows 
			| PHONE_TYPE_NM |PHONE_NBR    | EFCTV_DT     | END_DT | AREA_NBR | JRN_LCTN_ID      |  JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM |JRN_DT     | JRN_USER_ID |
			| "<phoneType>"	   |6585098   | Today -90    |Today    | 703	  |	<CorpProvided>	|     U               |    wuperson|            |		     	      | Today - 3 | VRCCGORT |
			| "<phoneType>"	   |6585093   | Today -90    |Today    | 703	  |	<CorpProvided>	|     U               |    wuperson|            |		     	      | Today  - 2|VRCCGORT |
		And commits the following record with "<VET360phoneType>" and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_DT | JRN_LCTN_ID         | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM |  
     		| "<phoneType>"	|6585098   | Today	  |	       | 703	  | Today  | 	<CorpProvided>	 |     Jane  |     I              |    VET360  |            |		VET360	        |	
	    Examples:
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|
		
	Scenario: Inserting new phone record in Corp
		Given the following vet360 person phone BIO received from the CUF changelog
			| SourceSystem |internationalInd | phoneType | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
			| VET360	   | False		     | Mobile    |   	1		 | 760	 	| 7574155	|        		 | False  | Today      | True       		    |  True                 | True               | Today              | Jane           | Vets.gov           |
		When the changelog BIO has PTCPNT_ID not equal to Corp records in PTCPNT_PHONE table 
		Then the Adapter commits the following new PTCPNT_PHONE record and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | AREA_NBR | JRN_LCTN_ID |   JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_DT |
			| Cellular	    |7574155   | Today    | 760	     |	<CorpProvided>	|     Jane  |     I              |    Vets.gov     |        |		VET360   |	Today|
		
	Scenario: Veteran retires and end-dates his work phone
		Given the following vet360 person phone BIO received from the CUF changelog
	    	| SourceSystem |internationalInd | phoneType | countryCode | effectiveEndDate| areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
    		| VET360	   | False		     | Work    |   	1		|   Today         | 760	 	| 7374155	|        		 | False  | Today      | True       		    |  True                 | True               | Today-90             | Jane           | Vets.gov           |
		When the changelog BIO effectiveEndDate is not NULL
		Then the Adapter will populate the END_DT field with the effectiveEndDate as follows and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_LCTN_ID      |   JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_DT |
			| Daytime	    |7374155   | Today-30 |  Today | 760	  |	<CorpProvided>	|     Jane      |     U              | Vets.gov   |            |		VET360       |	Today|

	Scenario: Veteran retires and end-dates his multiple work phones
		Given the following vet360 person phone BIO received from the CUF changelog 
			| SourceSystem |internationalInd | phoneType         | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|effectiveEndDate|
			| VET360		 | False		 | <VET360phoneType> |   	1		 | 703	 	| 6585098	  | 12345		 | False  | Today      | True       		    |  False               | True               | Today-30          	  | VHAISDFAULKJ   | ADR            | Today|
		When the changelog BIO has PTCPNT_ID equal to two Corp records in PTCPNT_PHONE table
		And END_DT is NULL
		Then the Adapter will populate the END_DT fields of the following records with the effectiveEndDateDate value and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_LCTN_ID      |   JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_DT |
			| Daytime	    |7574152   | Today-30 |  Today | 760	  |	<CorpProvided>	|     Jon        |     U              | Vets.gov   |            |		VET360        |	Today|
			| Daytime	    |7574151   | Today-22 |  Today | 760	  |	<CorpProvided>	|     Jane       |     U              | Vets.gov   |            |		VET360        |	Today|

	
