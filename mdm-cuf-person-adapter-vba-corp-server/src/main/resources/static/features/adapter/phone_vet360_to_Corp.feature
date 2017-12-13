##Drafted by Aramis Calderon (email: aramis.calderon@halfaker.com/ phone: 7608055923)
Feature: Adapt VET360 phone number BIO to Corp PTCPNT_PHONE data table
		As Department of Veterans Affairs Enterprise, I want to convert phone number records in VET360 to 
		VBA Corp phone records schema. 

    Definition of Terms
    - Matching: Returned PTCPNT_ID from MVI call equals the PTCPNT_ID of the destination table (PTCPNT_PHONE or PTCPNT_ADDRS)
    - Active: Current date falling between the EFCTV_DT and END_DT (or END_DT is null)
    - Delete: END_DT of Corp record will be equal to VET360 effectiveEndDate
    - Standardization: Vet360 CUF has modified the data that doesn't fundamentally change the contact info record 
    - Pristine: No change was made by the Vet360 CUF
    
    Assumptions:
	- International numbers will not be in scope for IOC.
	- Veteran records with 2 PARTICIPANT_IDs in MVI will be sent to the Error Queue and never populate in the changelog.
	- Any change pushed to Adapter to Corp by VET360 is already validated as an Living Veteran.
	- Adapter will be able to query existing records in Corp.
	- If no Corp correlated ID/participant ID is present in the CUF change log queue message then we will drop the change and post back to the CUF a COMPLETED_NOOP
	- Contact information change pushed out to Corp that matches records will be End-Dated even if the 
		core fields (e.g. area number, phone number, extension) are identical thus updating the provenance fields (i.e. the mapped JRN_XX columns)#Check before sending//
		
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
	- JRN_EXTNL_APPLCN_NM will have "vet360adapter" in the field.
	- JRN_OBJ_ID will have application name + action (e.g. “VET360PHONE”, “VET360AddressUp”, “VET360CONTACTUPDATE”). 
	- VET360 sourceSysUser populates JRN_EXTNL_USER_ID. 
	- JRN_USER_ID will have "VET360SYSACCT" in the field.
	- VET360 sourceSystem and orginatingSourceSys populates comma separated Corp JRN_EXTNL_KEY_TXT field; in that order.
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
				
	Scenario: Drop record if the Phone Type is an unexpected value with no mapping into Corp
		Given a valid VET360 person phone BIO received from the CUF changelog
		When the changelog BIO phoneType is not "<Work>", "<Home>", "<Fax>", or "<Mobile>"
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF
	
	Scenario: Dropping a Phone Number record that is not Domestic
		Given a valid VET360 person phone BIO received from the CUF changelog
		When the changelog BIO countryCode is not "<1>"
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF 
    
	Scenario: Dropping a Phone Number record that does not have a correlated PARTICIPANT_ID in MVI
		Given a valid VET360 person phone BIO received from the CUF changelog
		When the changelog BIO PARTICIPANT_ID is NULL
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF
	
	Scenario Outline: Dropping a "pristine" phone record that originated from Corp  
		Given the following VET360 person phone BIO received from the CUF changelog 
			| SourceSystem |internationalInd | phoneType         | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|effectiveEndDate|
			| Corp         | False		 	 | <VET360phoneType> |   	1	   | 305      | 6733493	    | 12345		     | False  | Today      | False       		    |  False                | False              | Today              | VSCLYARB       | VBMS  - CEST       |                |
		When the changelog BIO txtAuditId matches to a CDC_Staging_Corp_Table txtAuditId  
		And has PHONE_TYPE_NM of "<phoneType>"
		And phoneNumber equals PHONE_NBR
		And areaCode equals AREA_NBR
		And phoneNumberExt equals EXTNSN_NBR
		Then the Adapter will drop record and sends "COMPLETED_SUCCESS" to CUF 
		Examples:
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|

	Scenario Outline: Updating one existing record in Corp
		Given the following VET360 person phone BIO received from the CUF changelog 
			| SourceSystem |internationalInd | phoneType         | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
			| VET360		 | False		 | <VET360phoneType> |   	1	   | 703	  | 6585098     | 12345		     | False  | Today      | True       		    |  False                | True               | Today           	  | VHAISDFAULKJ   | ADR                |
		When the changelog BIO matches to a record in Corp Phone table in the database
		And the record is active
		And has PHONE_TYPE_NM of "<phoneType>"
		Then the Adapter will populate the END_DT field of the matching record with the changelog BIO effectiveStartDate value as follows
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_LCTN_ID |  JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM |JRN_DT     | JRN_USER_ID   | JRN_EXTNL_KEY_TXT      |JRN_EXTNL_USER_ID|
			| <phoneType>   |6585098   | Today -90|Today   | 703	  |	281       	|     U               | VET360PHONE|            |  vet360adapter      | Today     | VET360SYSACCT | VET360,ADR             | VHAISDFAULKJ    |
		And commits the following new PTCPNT_PHONE record with "<VET360phoneType>" and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_DT | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_EXTNL_KEY_TXT      |JRN_EXTNL_USER_ID|
     		| <phoneType>	|6585098   | Today	  |	       | 703	  | Today  | 	281      |VET360SYSACCT|     I              | VET360PHONE|  12345     |		vet360adapter   | VET360,ADR             |VHAISDFAULKJ     |
	    Examples:
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|
	
	Scenario Outline: VET360 update when Corp has multiple active phone types
		Given the following VET360 person phone BIOs received from the CUF changelog 
			| SourceSystem |internationalInd | phoneType           | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
			| VET360		 | False		 | <VET360phoneType>   |   	1		 | 703	 	| 6585098     | 12345          | False  | Today      | True       		      |  False                | True               | Today              | Jane           | Vets.gov             |
		When the changelog BIO matches to two Corp records in Corp Phone table in the database
		And the record is active
		And has PHONE_TYPE_NM of "<phoneType>"
		Then the Adapter will populate the END_DT fields of the matching record with changelog BIO effectiveStartDate value as follows 
			| PHONE_TYPE_NM |PHONE_NBR    | EFCTV_DT     | END_DT | AREA_NBR | JRN_LCTN_ID  |  JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM |JRN_DT | JRN_USER_ID  |JRN_EXTNL_USER_ID|
			| <phoneType>	   |6585098   | Today -90    |Today   | 703	     |	281      	|     U               | VET360PHONE|            |	vet360adapter     | Today | VET360SYSACCT|Jane             |
			| <phoneType>	   |6585093   | Today -90    |Today   | 703	     |	281     	|     U               | VET360PHONE|            |	vet360adapter     | Today |VET360SYSACCT |Jane             |
		And commits the following record with "<VET360phoneType>" and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_DT | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_EXTNL_KEY_TXT      | JRN_EXTNL_USER_ID|
     		| <phoneType>	|6585098   | Today	  |	       | 703	  | Today  | 	281   	 |VET360SYSACCT|     I              |VET360PHONE |            |		vet360adapter   |VET360,Vets.gov         |Jane           |
	    Examples:
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|
		
	Scenario Outline: Inserting new phone record in Corp
		Given the following VET360 person phone BIO received from the CUF changelog
			| SourceSystem |internationalInd | phoneType          | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
			| VET360	   | False		     | <VET360phoneType>  |   	1	    | 760      | 7574155	 |          	  | False  | Today      | True       		     |  True                 | True               | Today              | Jane           | Vets.gov           |
		When the changelog BIO does not match to a record in Corp Phone table in the database
		Then the Adapter commits the following new PTCPNT_PHONE record and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | AREA_NBR | JRN_LCTN_ID  |   JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_DT |JRN_EXTNL_KEY_TXT      | JRN_EXTNL_USER_ID|
			| <phoneType>   |7574155   | Today    | 760	     |	281      	| VET360SYSACCT |     I              | VET360PHONE|            |	vet360adapter    | Today  |VET360,Vets.gov        | Jane             |
		Examples:   
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|

	Scenario: Phone BIO does not have sourceSysUser provenance field populated
		Given the following VET360 person phone BIO received from the CUF changelog
	    	| SourceSystem |internationalInd | phoneType | countryCode | effectiveEndDate| areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
    		| ADR    	   | False		     | Work      |   	1	   |   Today         | 760	 	| 7374155	  |        		   | False  | Today      | True       		      |  True                 | True               | Today-90           |                |    VAMC-549        |
    	When sourceSysUser is NULL
 		Then the Adapter commits the following new PTCPNT_PHONE record, populates JRN_EXTNL_USER_ID with value "UNK_USER" and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | AREA_NBR | JRN_LCTN_ID  |   JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_DT |JRN_EXTNL_KEY_TXT      |JRN_EXTNL_USER_ID|
			| Daytime       |7574155   | Today    | 760	     |	281      	| VET360SYSACCT |     I              | VET360PHONE|            |	vet360adapter    | Today  |ADR,VAMC-549           | UNK_USER        |

	Scenario: Phone BIO does not have orginatingSourceSys provenance field populated
		Given the following VET360 person phone BIO received from the CUF changelog
	    	| SourceSystem |internationalInd | phoneType   | countryCode | effectiveEndDate| areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
    		| ADR    	   | False		     | work        |   	1	   |   Today           | 760	 	| 7374155	  |        		   | False  | Today      | True       		      |  True                 | True               | Today-90             | Jane Wayne     |                    |
    	When orginatingSourceSys is NULL
 		Then the Adapter commits the following new PTCPNT_PHONE record, appends "UNK_OSS" to JRN_EXTNL_KEY_TXT and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | AREA_NBR | JRN_LCTN_ID  |   JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_DT |JRN_EXTNL_KEY_TXT      |JRN_EXTNL_USER_ID|
			| Daytime       |7574155   | Today    | 760	     |	281      	| VET360SYSACCT |     I              | VET360PHONE|            |	vet360adapter    | Today  |ADR,UNK_OSS            |Jane Wayne       |

	Scenario: Phone BIO does not have orginatingSourceSys and sourceSysUser provenance fields populated
		Given the following VET360 person phone BIO received from the CUF changelog
	    	| SourceSystem |internationalInd | phoneType   | countryCode | effectiveEndDate| areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
    		| ADR    	   | False		     | work        |   	1	   |   Today           | 760	 	| 7374155	  |        		   | False  | Today      | True       		    |  True                 | True               | Today-90           |                |                    |
    	When orginatingSourceSys is NULL
    	And sourceSysUser is NULL
 		Then the Adapter commits the following new PTCPNT_PHONE record, appends "UNK_OSS" to JRN_EXTNL_KEY_TXT, populates JRN_EXTNL_USER_ID with value "UNK_USER", and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | AREA_NBR | JRN_LCTN_ID  |   JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_DT |JRN_EXTNL_KEY_TXT      |JRN_EXTNL_USER_ID|
			| Daytime       |7574155   | Today    | 760	     |	281      	| VET360SYSACCT |     I              | VET360PHONE|            |	vet360adapter    | Today  |ADR,UNK_OSS            |UNK_USER         |  

	Scenario Outline: Veteran deletes phone record
		Given the following VET360 person phone BIO received from the CUF changelog
	    	| SourceSystem |internationalInd | phoneType         | countryCode | effectiveEndDate| areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|
    		| VET360	   | False		     | <VET360phoneType> |   	1		|   Today         | 760	 	| 7374155	  |        		   | False  | Today      | True       		    |  True                 | True                 | Today-90             | Jane           | Vets.gov           |
		When the changelog BIO matches to a record in Corp Phone table in the database 
		And effectiveEndDate is not NULL
		Then the Adapter will populate the END_DT field with the effectiveEndDate as follows and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_LCTN_ID  |   JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_DT |JRN_EXTNL_KEY_TXT      |JRN_EXTNL_USER_ID|
			| <phoneType>   |7374155   | Today-30 |  Today | 760	  |	281     	 | VET360SYSACCT |     U             | VET360PHONE |            | vet360adapter       |	Today  |VET360,Vets.gov        |Jane             |
		Examples:
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|

	Scenario Outline: Veteran retires and deletes multiple work phones
		Given the following VET360 person phone BIO received from the CUF changelog 
			| SourceSystem |internationalInd | phoneType         | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|effectiveEndDate|
			| VET360		 | False		 | <VET360phoneType> |   	1		 | 703	 	| 6585098	  | 12345		 | False  | Today      | True       		    |  False               | True               | Today-30          	  | VHAISDFAULKJ   | ADR            | Today|
		When the changelog BIO matches to two Corp records in Corp Phone table in the database
		And END_DT is NULL
		Then the Adapter will populate the END_DT fields of the following records with the effectiveEndDateDate value and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_LCTN_ID |   JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM | JRN_DT  |JRN_EXTNL_KEY_TXT        |JRN_EXTNL_USER_ID|
			| <phoneType>   |7574152   | Today-30 |  Today | 760	  |	281      	|  VET360SYSACCT|     U              | VET360PHONE|            | vet360adapter       |	Today  |VET360,Vets.gov          |Jane			   |
			| <phoneType>   |7574151   | Today-22 |  Today | 760	  | 281       	|  VET360SYSACCT|     U              | VET360PHONE|            | vet360adapter       |	Today  |VET360,Vets.gov          |Jane             |
	    Examples:
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|
	
	Scenario Outline: Phone record "core" fields from non-Corp source is identical to active Corp record
		Given the following VET360 person phone BIO received from the CUF changelog 
			| SourceSystem |internationalInd | phoneType         | countryCode | areaCode | phoneNumber | phoneNumberExt | ttyInd | sourceDate | voiceMailAcceptableInd | textMessageCapableInd | textMessagePermInd | effectiveStartDate | sourceSysUser  | orginatingSourceSys|effectiveEndDate|
			| VHAES   	   | False		 	 | <VET360phoneType> |   	1	   | 305      | 6733493	    | 12345		     | False  | Today      | True       		    |  False                | True               | Today              |                | VAMC               |                |
		When the changelog BIO matches to a record in Corp Phone table in the database
		And the record is active
		And has PHONE_TYPE_NM of "<phoneType>"
		And phoneNumber equals PHONE_NBR
		And areaCode equals AREA_NBR
		And phoneNumberExt equals EXTNSN_NBR
		Then the Adapter will populate the END_DT field of the matching record with the changelog BIO effectiveStartDate value as follows
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_LCTN_ID |  JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM |JRN_DT     | JRN_USER_ID   | JRN_EXTNL_KEY_TXT      |JRN_EXTNL_USER_ID|
			| <phoneType>   |6733493   | Today -90|Today   | 305	  |	281       	|     U               | VET360PHONE| 12345      |  vet360adapter      | Today     | VET360SYSACCT | VAMC,VHAES             | UNK_USER    |
		And commits the following new PTCPNT_PHONE record and sends "COMPLETED_SUCCESS" response to CUF
			| PHONE_TYPE_NM |PHONE_NBR | EFCTV_DT | END_DT | AREA_NBR | JRN_LCTN_ID |  JRN_STATUS_TYPE_CD | JRN_OBJ_ID | EXTNSN_NBR | JRN_EXTNL_APPLCN_NM |JRN_DT     | JRN_USER_ID   | JRN_EXTNL_KEY_TXT      |JRN_EXTNL_USER_ID|
			| <phoneType>   |6733493   | Today    |        | 305	  |	281       	|     I               | VET360PHONE| 12345      |  vet360adapter      | Today     | VET360SYSACCT | VAMC,VHAES             | UNK_USER    |
	    Examples:
		| phoneType |VET360phoneType|
		|Daytime    |Work  |
		|Nighttime  |Home  |
		|Fax        |Fax   |
		|Cellular   |Mobile|
	
