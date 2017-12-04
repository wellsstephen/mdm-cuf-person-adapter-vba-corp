##Drafted by Aramis Calderon (email: aramis.calderon@halfaker.com/ phone: 7608055923)##
Feature: Adapt VBA Corp phone number DIO to VET360 phone record table
		As Department of Veterans Affairs Enterprise, I want to convert phone number records in VBA Corp to VET360
		phone records schema. 

    Assumptions:
	- Corp Person table will be the authoritative source of Veteran identity. 
	- International numbers will not be in scope for IOC.
	- Phone type of Other, Pager, & International will not be synced with VET360.
	
	GoldenGate Assumptions:
	- Corp-CDC-Staging-Table filter will only provide an Phone specific DB view/table.
	- Corp-CDC-Staging-Table Phone specific DB view/table will only expose mapped fields that are required for changes.
	- Corp-CDC-Staging-Table will ONLY stage records where PHONE_TYPE_NM equals "Daytime", "Nighttime", "Fax", or "Celluar".
	- Adapter will not check if a record is active and belongs to a living veteran without a fiduciaury.
	
	
    Field Mappings:
	- VET360 record is created with effectiveStartDate matching Corp EFCTV_DT.
	- Daytime PHONE_TYPE_NM value from Corp maps to VET360 phoneType Work.
	- Nighttime PHONE_TYPE_NM value from Corp maps to VET360 phoneType Home.
	- Celluar PHONE_TYPE_NM value from Corp maps to VET360 phoneType Mobile.
	- Fax PHONE_TYPE_NM value from Corp maps to VET360 phoneType Fax.
	- Corp PHONE_NBR populates VET360 phoneNumber field.
	- Corp PHONE_TYPE_NM populates VET360 phoneType field.
	- Corp AREA_NBR populates VET360 areaCode field.
	- Corp EXTNSN_NBR removes non-numeric characters and populates VET360 phoneNumberExt field.
	- Corp EFCTV_DT populates VET360 effectiveStartDate field.
	- Corp END_DT maps to effectiveEndDate field.
	- Corp JRN_DT populates VET360 sourceDate field.
	- Corp JRN_OBJ_ID populates VET360 orginatingSourceSys field.
	- Corp JRN_USER_ID populates VET360 sourceSysUser field.
	- VET360 sourceSystem value will be derived from header data.

	
	Background: Veteran phone record from Corp PTCPNT_PHONE table to VET360 adapted table.
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
			| Attribute Name							| Column Name			| Mandatory/Optional		| Type          |	Length |		
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
				
		Given the system has defined a valid 7 digit Domestic Phone Number
			| attrbuteName          | value                 |
			| AREA_NBR				| 703					| 					
			| CNTRY_NBR				| null					| 
			| EFCTV_DT				| Today-30				|
			| END_DT				| null					| 
			| EXTNSN_NBR			| x234					| 
			| FRGN_PHONE_RFRNC_TXT	| null					| 
			| JRN_DT				| Today-30				| 
			| JRN_EXTNL_APPLCN_NM	| null					| 
   			| JRN_EXTNL_KEY_TXT		| null					| 
			| JRN_EXTNL_USER_ID		| null					| 
			| JRN_LCTN_ID			| 341					| 
			| JRN_OBJ_ID			| CRMUD  - CADD			|
			| JRN_STATUS_TYPE_CD	| I  					| 
			| JRN_USER_ID			| VBASLCPIENEJ			| 
			| PHONE_NBR				| 4343900				| 
			| PHONE_TYPE_NM			| Nighttime				| 
			| PTCPNT_ID				| 1						|		
			
		Given the system has defined a valid 10 digit Domestic Phone Number
			| attrbuteName          | value                 |
			| AREA_NBR				| null					| 					
			| CNTRY_NBR				| null					| 
			| EFCTV_DT				| Today-90				|
			| END_DT				| null					| 
			| EXTNSN_NBR			| null					| 
			| FRGN_PHONE_RFRNC_TXT	| null					| 
			| JRN_DT				| Today-10				| 
			| JRN_EXTNL_APPLCN_NM	| null					| 
   			| JRN_EXTNL_KEY_TXT		| null					| 
			| JRN_EXTNL_USER_ID		| null					| 
			| JRN_LCTN_ID			| 311					| 
			| JRN_OBJ_ID			| VBMS  - CEST 			|
			| JRN_STATUS_TYPE_CD	| U  					| 
			| JRN_USER_ID			| VBAPITALFREJ			| 
			| PHONE_NBR				| 7034343900			| 
			| PHONE_TYPE_NM			| Daytime				| 
			| PTCPNT_ID				| 2						|	
	
	Scenario Outline: Drop record if the Phone Type is not to be synchronized with VET360
		Given a valid 7 digit person Domestic Phone Number DIO received from the Corp-CDC-Staging-Table
		When existing PHONE_TYPE_NM is "<phoneType>"
		Then the Adapter will drop record and send "COMPLETED_NOOP" to Corp-CDC-Staging-Table
		Examples:
		| phoneType |
		|Other |
		|International|
		|Pager|
		
	Scenario: Dropping a Phone Number record that is not Domestic
		Given the following person phone record DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT  | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID     | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Nighttime     |9183347966| Today-25 | 		 |  		| 600		|      				   |Today-12 | 	329        | VRCCGORT    |          I         | wuperson       |      	    |  				    |				    |					  |	
		When CNTRY_NBR is not null or 0
		Then the Adapter will drop record and send "COMPLETED_NOOP" to Corp-CDC-Staging-Table
		
	Scenario: Identifying a 7-digit Domestic Phone Number 
		Given the following person phone record DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Daytime		  |1111111	 | Today	| 		 | 703		| 			|      				   |Today-30| 	309		  | VREWESPA    |          U         | wueduprv   |      	   |  				   |				   |					 |	
		When PHONE_NBR is length 7
		And AREA_NBR is length 3
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO and send through Maintenance-Endpoint which will return a "RECEIVED" response to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber | phoneType | sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|
			| False		      |    	1		|   703    | 1111111     | Work      |Today-30    | "Corp"       | wueduprv            | VREWESPA      |Today             |
		
	Scenario: Identifying a 10-digit Domestic Phone Number with no area code 
		Given the following person phone record DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT  | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID     | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Celluar       |7038842312| Today-180| 	   |  		  | 		  |      				 |Today-30 | 	351      | VBAMUSLEONAB|          U         | SHARE  - CEST  |      	   |  				   |				   |					 |	
		When PHONE_NBR is length 10
		And AREA_NBR is null
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO and send through Maintenance-Endpoint which will return a "RECEIVED" response to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber | phoneType | sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|
			| False		      |    	1		|   703    | 8842312     | Mobile |   Today-180    | "Corp"       | SHARE  - CEST    | VBAMUSLEONAB      |Today-30        |
		
	Scenario: Identifying a 10-digit Domestic Phone Number with Matching Area Code 
		Given the following person phone record DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT  | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID     | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Fax           |7032457656| Today-780| 		 |  703		| 			|      				   |Today-780| 	402        | VREPMCKE    |          I         | wuperson       |      	    |  				    |				    |					  |	
		When PHONE_NBR is length 10
		And AREA_NBR matches first 3 characters of PHONE_NBR
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO and send through Maintenance-Endpoint which will return a "RECEIVED" response to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber |phoneType | sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|
			| False		      |    	1		|   703    | 2457656     | Fax       |Today-780  | "Corp"       | wuperson            | VREPMCKE      |Today-780        |
		
	Scenario: Identifying a 10-digit Domestic Phone Number with Non-Matching Area Code 
		Given the following person phone record DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT  | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID     | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Nighttime     |7037277966| Today-25 | 		 |  610		| 			|      				   |Today-12 | 	329        | VRCCGORT    |          U         | wuperson       |      	    |  				    |				    |					  |	
		When PHONE_NBR is length 10
		And AREA_NBR does not match first 3 characters of PHONE_NBR
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO and send to Maintenance-Endpoint which will return "RECEIVED_ERROR_QUEUE" to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber | phoneType |sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|
			| False		      |    	1		|   610    | 7037277966   | Home     |Today-12    | "Corp"       | wuperson            | VRCCGORT      |Today-25             |
		
	Scenario: Updating a Phone record in VET360 
		Given the following person phone record DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Daytime		 |8675309  | Today    | 		| 703	  | 		  |      				 |Today | 	309		| VREWESPA    |          I         | wueduprv   |      	   |  				   |				   |					 |	
        When Phone record DIO PTCPNT_ID received from the Corp-CDC-Staging-Table correlates to VET360Id 
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO, does not populate effectiveStartDate with EFCTV_DT, and send through Maintenance-Endpoint which will return "RECEIVED_ERROR_QUEUE" to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber | phoneType | sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|
			| False		      |    	1		|   703    | 8675309     | Work      |Today       | "Corp"       | wueduprv            | VREWESPA      |Today-30          |
		
	Scenario: Identifying a Malformed Domestic Phone Number and Passing to CUF
		Given the following person phone record DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT   | END_DT   | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT  | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID     | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Daytime       |11		 | Today-1000 | 		 |  		| 			|      				   |Today-12 | 	309        | VRCDLEON    |          U         | wueduprv       |      	    |  				    |				    |					  |	
		When PHONE_NBR is not length 10 or 7
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO and send to Maintenance-Endpoint which will return "RECEIVED_ERROR_QUEUE" to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber | phoneType |sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|
			| False		      |    	1		|          | 11			 | Work      | Today-12    | "Corp"       | wueduprv            | VRCDLEON      |Today-1000      |
		
	Scenario: Identifying a Malformed Domestic Area Number and Passing to CUF
		Given the following person phone record DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT   | END_DT   | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT  | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID     | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Daytime       |6172299	 | Today-100  | 		 |  8414	| 			|      				   |Today-12 | 	309        | VRCDLEON    |          U         | wueduprv       |      	    |  				    |				    |					  |	
		When AREA_NBR is not null and not length 3
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO and send to Maintenance-Endpoint which will return "RECEIVED_ERROR_QUEUE" to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber | phoneType |sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|
			| False		      |    	1		|   8414   | 6172299     | Work      | Today-12  | "Corp"       | wueduprv            | VRCDLEON      |Today-100            |

    Scenario: Identifying an Incomplete Domestic Phone Number and Passing to CUF
		Given the following person phone record DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT   | END_DT   | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT  | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID     | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Daytime       |6173329   | Today-28   | 		   |  		  | 		  |      				   |Today-12 | 	309        | VRCDLEON    |          U         | wueduprv       |      	    |  				    |				    |					  |	
		When PHONE_NBR length is 7
		And AREA_NBR is null
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO and send to Maintenance-Endpoint which will return "RECEIVED_ERROR_QUEUE" to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber |phoneType |sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|
			| False		      |    	1		|          | 6173329	 | Work     | Today-12  | "Corp"       | wueduprv            | VRCDLEON     |Today-28        |
			
	Scenario: Remove Non-Numeric Characters from Extension Numbers
		Given the following veteran domestic phone record exists DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT   | END_DT   | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT  | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID     | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Daytime       |7123899   | Today-10   | 		   |  703     | 		  |      				 |Today-1  | 	309      | VRCDLEON    |          U         | wueduprv       |  ext12     |  				  |				     |					    |	
		When EXTNSN_NBR is not null
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO and send through Maintenance-Endpoint which will return "RECEIVED" response to Corp-CDC-Staging-Table
			| sourceSystem |internationalInd | phoneType | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | effectiveEndDate | connectionStatusCode| ConfDate | orginatingSourceSys |sourceSysUser|telephoneId|
			| Corp		 | False		   | Work      |   	1		 |   703 	| 7123899     | 12     		   |        | Today-1    |          			  |                       |                    | Today-10         	| 	               |                     |          |   wueduprv          |VRCDLEON     |           |

	Scenario Outline: Accepts record if the Phone Type is to be synchronized with VET360
		Given the valid 10 digit Domestic Phone Number DIO received from the Corp-CDC-Staging-Table
		When existing PHONE_TYPE_NM is "<phoneType>"
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO with "<VET360phoneType>" and send to Maintenance-Endpoint which will return "RECEIVED" respone to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber |phoneType           | sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|
			| False		      |    	1		 |   703 	| 4343900    |"<VET360phoneType>" | Today-30    | "Corp"       | wueduprv            | VREWESPA      |Today             |
		Examples:
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|

	Scenario: Accepts record of unexpected Phone Type will be sent to VET360
		Given the following Domestic Phone Number DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM        |PHONE_NBR | EFCTV_DT   | END_DT   | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT  | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID     | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| SubspaceCommunicator |7123899   | Today-10   | Today    |  703     | 		  |      				 |Today-1  | 	309      | VRCDLEON    |          U         | wueduprv       |  ext12     |  				  |				     |					    |	

		When existing PHONE_TYPE_NM is not "<Other>", "<International>", "<Pager>", "<Fax>", "<Cellular>", "<Daytime>", or "<Nighttime>" 
		Then the Adapter will convert the Domestic Phone Number to the following VET360 BIO and send to Maintenance-Endpoint which will return "RECEIVED_ERROR_QUEUE" to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber| phoneType           | sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|
			| False		      |    	1		|   703    | 4343900    |SubspaceCommunicator | Today      | "Corp"       | wueduprv            | VREWESPA      |Today             |

	Scenario: End-date a Phone record with a different phone number value in VET360 
		Given the following person Email record DIO received from the Corp-CDC-Staging-Table
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT   | END_DT   | AREA_NBR | CNTRY_NBR | FRGN_PHONE_RFRNC_TXT | JRN_DT  | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID     | EXTNSN_NBR | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM |  
			| Daytime       |7123899   | Today-10   | Today    |  703     | 		  |      				 |Today-1  | 	309      | VRCDLEON    |          U         | wueduprv       |  ext12     |  				  |				     |					    |	
		When Phone record DIO PTCPNT_ID received from the Corp-CDC-Staging-Table correlates to VET360Id  
		And the phoneNumber does not equal to PHONE_NBR
		Then the Adapter will convert the Phone to the following VET360 BIO and send through Maintenance-Endpoint which will return "RECEIVED_ERROR_QUEUE" to Corp-CDC-Staging-Table
			|internationalInd | countryCode | areaCode | phoneNumber |sourceDate | sourceSystem | orginatingSourceSys | sourceSysUser |effectiveStartDate|effectiveEndDate|
			| False		      |    	1		|   703    | 7123844     | Today     | "Corp"       | wueduprv            | VREWESPA      |Today-30          | Today          |
			