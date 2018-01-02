##Drafted by Aramis Calderon (email: aramis.calderon@halfaker.com/ phone: 7608055923)
Feature: Adapt VET360 Address BIO to Corp Address data table
		As Department of Veterans Affairs Enterprise, I want to convert Address records in VET360 to VBA Corp Address records schema. 

	Definition of Terms
    - Matching: Returned PTCPNT_ID from MVI call equals the PTCPNT_ID of the destination table (PTCPNT_PHONE or PTCPNT_ADDRS)
    - Active: Current date falling between the EFCTV_DT and END_DT (or END_DT is null)
    - Delete: END_DT of Corp record will be equal to VET360 effectiveEndDate
    - Cleansing: Vet360 CUF has modified the data that doesn't fundamentally change the contact info record 
    - Pristine: No change was made by the Vet360 CUF
	
	Assumptions:
	- Veteran records with 2 PARTICIPANT_IDs will be sent to the Error Queue and never populated in the changelog.
	- Any change pushed to Corp by VET360 is already validated as an Alive Veteran.
	- Adapter will be able to query existing records in Corp
	- If no Corp correlated ID/participant ID is present in the CUF change log queue message then we will drop the change and post back to the CUF a COMPLETED_NOOP
	- Contact information change pushed out to Corp that matches records will be End-Dated even if the 
		core fields (e.g. email text) are identical thus updating the provenance fields (i.e. the mapped JRN_XX columns)
    - Adapter has to check fiduciary and benefits information
	
    Field Mappings:
	- Corp EFCTV_DT is VET360 effectiveStartDate.
	- VET360 addressLine1 field populates Corp ADDRS_ONE_TXT.
	- VET360 addressLine2 field populates Corp ADDRS_TWO_TXT.
	- VET360 addressLine3 field populates Corp ADDRS_THREE_TXT.
	- VET360 cityName field populates Corp CITY_NM . 
	- VET360 countyName field populates Corp COUNTY_NM .
	- VET360 zipCode5 field populates Corp ZIP_PREFIX_NBR . 
	- VET360 zipCode4 field populates Corp ZIP_FIRST_SUFFIX_NBR .
	- VET360 stateCode field populates Corp POSTAL_CD.
	- VET360 countryName field populates Corp CNTRY_TYPE_NM.
	- VET360 badAddressIndicator field populates Corp BAD_ADDRS_IND ; post-IOC.
	- VET360 intPostalCode field populates Corp FRGN_POSTAL_CD.
	- VET360 provinceName field populates Corp PRVNC_NM.
	- VET360 effectiveStartDate field populates Corp EFCTV_DT.
	- VET360 sourceDate field populates Corp JRN_DT.
	- When updating an existing record the previous values of BENE_NM, FID_NM, BENE_NM_MODIFD_IND, FID_NM_MODIFD_IND, and PRPTNL_PHRASE_TYPE_NM columns must be kept for the new record.
	- JRN_EXTNL_APPLCN_NM will have "vet360adapter" in the field.
	- VET360 sourceSysUser populates JRN_EXTNL_USER_ID.
	- JRN_OBJ_ID will have application name + action (e.g. “VET360PHONE”, “VET360AddressUp”, “VET360CONTACTUPDATE”). 
	- JRN_USER_ID will have "VET360SYSACCT" in the field.
    - VET360 sourceSystem and orginatingSourceSys populates comma separated Corp JRN_EXTNL_KEY_TXT field; in that order.
	- Corp JRN_LCTN_ID value will be derived from service.
	- Corp JRN_STATUS_TYPE_CD value will be derived from type of transaction (logical delete/update or new record).
		
 	Background: Veteran Address record from VET360 to Corp PTCPNT_ADDRS table.
 		Given Address BIO schema
      | Attribute Name            | Coded Value         | Mandatory/Optional | Type            | BIO Field Length | Stored Field Length | Standard | common/core |
      | Address ID                | addressID           | Mandatory          | String          | 255              | 255                 | none     | core        |
      | Originating Source System | orginatingSourceSys | Optional           | String          | 255              | 255                 | none     | core        |
      | Source System             | sourceSystem        | Optional           | String          | 255              | 255                 | none     | core        |
      | Source System User        | sourceSysUser       | Optional           | String          | 255              | 255                 | none     | core        |
      | Source Date               | sourceDate          | Mandatory          | Date/Time (GMT) |                  |                     | ISO 8601 | core        |
      | Confirmation Date         | addressConfDate     | Optional           | Date            |                  |                     | ISO 8601 |             |
      | Effective Start Date      | effectiveStartDate  | Mandatory          | Date            |                  |                     | ISO 8601 |             |
      | Effective End Date        | effectiveEndDate    | Optional           | Date            |                  |                     | ISO 8601 |             |
      | Address Type              | addressType         | Optional           | String          | 35               | 35                    | none     |             |
      | Address Purpose of Use    | addressPOU          | Mandatory          | enumerated list |                  |                     | none     |             |
      | Bad Address Indicator     | badAddressIndicator | Optional           | String          | 35               | 35                    | none     |             |
      | Address Line 1            | addressLine1        | Optional           | String          | 100              | 35                  | USPS/UPN |             |
      | Address Line 2            | addressLine2        | Optional           | String          | 100              | 35                  | USPS/UPN |             |
      | Address Line 3            | addressLine3        | Optional           | String          | 100              | 35                  | USPS/UPN |             |
      | City Name                 | cityName            | Optional           | String          | 100              | 35                  | USPS/UPN |             |
      | State Code                | stateCode           | Optional           | String          | 2                | 2                   | USPS P59 |             |
      | Zip Code 5                | zipCode5            | Optional           | String          | 5                | 5                   | USPS     |             |
      | Zip Code 4                | zipCode4            | Optional           | String          | 4                | 4                   | USPS     |             |
      | Province Name             | provinceName        | Optional           | String          | 100              | 40                  | USPS/UPN |             |
      | International Postal Code | intPostalCode       | Optional           | String          | 100              | 40                  | UPN      |             |
      | Country Name ISO3         | countryName         | Optional           | String          | 35               | 35                  | ISO 3166 |             |
      | CountryCode FIPS          | countryCodeFIPS     | Optional           | String          | 3                | 2                   | FIPS     |             |
      | CountryCode ISO2          | countryCodeISO2     | Optional           | String          | 3                | 2                   | ISO 3166 |             |
      | CountryCode ISO3          | countryCodeISO3     | Optional           | String          | 3                | 3                   | ISO 3166 |             |
      | Confidence Score          | confidenceScore     | Optional           | String          | 3                | 3                   | none     |             |
      | Latitude Coordinate       | latitude            | Optional           | String          | 35               | 35                  | USPS/UPN |             |
      | Longitude Coordinate      | longitude           | Optional           | String          | 35               | 35                  | USPS/UPN |             |
      | Geocode Precision Level   | geocodePrecision    | Optional           | String          | 35               | 35                  | USPS/UPN |             |
      | Geocode Calculated Date   | geocodeDate         | Optional           | Date            | 35               | 35                  | ISO 8601 |             |

  #Change Request Underway
      | Override Indicator        | overrideIndicator   | Optional           | String          | 35               | 35                  | none     |             |
      | County Name               | countyName          | Optional           | String          | 35               | 35                  | none     |             |
  #Post IOC Field
      | Confidential Use Type     | confidentialUseType | Optional | string | 35 | 35 | none |  |
  #To Be Removed upon Data Model revised and approved
      | Code-1 Correction Type      | correctionType            | Optional | string | 35 | 35 | none |  |
      | Code-1 Correction Text      | correctionText            | Optional | string | 35 | 35 | none |  |
      | Bad Address Reason          | badAddressReason          | Optional | string | 35 | 35 | none |  |
      | Temporary Address Indicator | temporaryAddressIndicator | Optional | string | 35 | 35 | none |  |
		
	Given VBA Corp Schema for PTCPNT_ADDRS
		| Attribute Name						            | Column Name			    | Mandatory/Optional | Type         | Length |	
		| PARTICIPANT ADDRESS TYPE NAME 		            | PTCPNT_ADDRS_TYPE_NM      | Mandatory			 | VARCHAR2 	|	50  |						
		| PARTICIPANT ADDRESS EFFECTIVE DATE	            | EFCTV_DT 			        | Mandatory			 | DATE		    |		|
		| PARTICIPANT ADDRESS ONE TEXT			            | ADDRS_ONE_TXT 		    | Optional			 | VARCHAR2 	|	35	|
		| PARTICIPANT ADDRESS TWO TEXT			            | ADDRS_TWO_TXT 		    | Optional			 | VARCHAR2 	|	35	|
		| PARTICIPANT ADDRESS THREE TEXT		            | ADDRS_THREE_TXT 		    | Optional			 | VARCHAR2 	|	35	|
		| PARTICIPANT ADDRESS CITY NAME			            | CITY_NM 	                | Optional	         | VARCHAR2     |	30	|
		| PARTICIPANT ADDRESS COUNTY NAME		            | COUNTY_NM 			    | Optional			 | VARCHAR2  	|	30	|
		| PARTICIPANT ADDRESS ZIP CODE PREFIX NUMBER        | ZIP_PREFIX_NBR 	        | Optional			 | VARCHAR2 	|	5	|
		| PARTICIPANT ADDRESS ZIP CODE FIRST SUFFIX NUMBER  | ZIP_FIRST_SUFFIX_NBR      | Optional			 | VARCHAR2 	|	4	|
		| PARTICIPANT ADDRESS ZIP CODE SECOND SUFFIX NUMBER | ZIP_SECOND_SUFFIX_NBR     | Optional			 | VARCHAR2 	|	2	|
		| PARTICIPANT ADDRESS END DATE			            | END_DT 			        | Optional			 | DATE      	|		|
		| PARTICIPANT ADDRESS POSTAL CODE		            | POSTAL_CD 			    | Optional			 | VARCHAR2     |	2	|
		| PARTICIPANT ADDRESS COUNTRY TYPE NAME	            | CNTRY_TYPE_NM 	        | Optional			 | VARCHAR2 	|	50	|
		| PARTICIPANT ADDRESS BAD ADDRESS INDICATOR         | BAD_ADDRS_IND 	        | Optional			 | VARCHAR2 	|	1	|
		| PARTICIPANT ADDRESS MILITARY POSTAL TYPE CODE     | EMAIL_ADDRS_TXT 		    | Optional			 | VARCHAR2     |  254	|
		| PARTICIPANT ADDRESS MILITARY POSTAL TYPE CODE     | MLTY_POSTAL_TYPE_CD 	    | Optional			 | VARCHAR2 	|	12	|
		| PARTICIPANT ADDRESS MILITARY POST OFFICE TYPE CODE| MLTY_POST_OFFICE_TYPE_CD  | Optional			 | VARCHAR2     |	12	|
		| PARTICIPANT ADDRESS FOREIGN POSTAL CODE           | FRGN_POSTAL_CD            | Optional           | VARCHAR2     |	16	|
		| PARTICIPANT ADDRESS PROVINCE NAME                 | PRVNC_NM                  | Optional           | VARCHAR2     |	35	|
		| PARTICIPANT ADDRESS TERRITORY NAME                | TRTRY_NM                  | Optional           | VARCHAR2     |  	35	|      
		| JOURNAL DATE                                      | JRN_DT                    | Mandatory          | DATE        	|          
		| JOURNAL LOCATION IDENTIFIER                       | JRN_LCTN_ID               | Mandatory          | VARCHAR2     |	4	|          
		| JOURNAL USER IDENTIFIER                           | JRN_USER_ID               | Mandatory          | VARCHAR2 	|	50	|          
		| JOURNAL STATUS TYPE CODE                          | JRN_STATUS_TYPE_CD        | Mandatory          | VARCHAR2     |	12	|         
		| JOURNAL OBJECT IDENTIFIER                         | JRN_OBJ_ID                | Mandatory          | VARCHAR2     | 	32	|         
		| PARTICIPANT ADDRESS IDENTIFIER                    | PTCPNT_ADDRS_ID           | Mandatory          | NUMBER   	|  	15	|        
		| GROUP1 VERIFIED TYPE CODE                         | GROUP1_VERIFD_TYPE_CD     | Optional           | VARCHAR2 	|  	12	|        
		| JOURNAL EXTERNAL USER IDENTIFER                   | JRN_EXTNL_USER_ID         | Optional           | VARCHAR2 	|   50	|       
		| JOURNAL EXTERNAL KEY TEXT                         | JRN_EXTNL_KEY_TXT         | Optional           | VARCHAR2 	|   50	|	          
		| JOURNAL EXTERNAL APPLICATION NAME                 | JRN_EXTNL_APPLCN_NM       | Optional           | VARCHAR2 	|   50	|          
		| JOURNAL DATE                                      | CREATE_DT                 | Optional           | DATE       	|   	|          
		| JOURNAL LOCATION IDENTIFIER                       | CREATE_LCTN_ID            | Optional           | VARCHAR2  	|    4	|         
		| JOURNAL USER IDENTIFIER                           | CREATE_USER_ID            | Optional           | VARCHAR2     |   50	|         
		| JOURNAL OBJECT IDENTIFIER                         | CREATE_OBJ_ID             | Optional           | VARCHAR2     |   32	|          
		| JOURNAL EXTERNAL USER IDENTIFER                   | CREATE_EXTNL_USER_ID      | Optional           | VARCHAR2     |   50	|          
		| JOURNAL EXTERNAL KEY TEXT                         | CREATE_EXTNL_KEY_TXT      | Optional           | VARCHAR2 	|   50	|          
		| JOURNAL EXTERNAL APPLICATION NAME                 | CREATE_EXTNL_APPLCN_NM    | Optional           | VARCHAR2     |   50	|    
		| PARTICIPANT ADDRESS SHARED ADDRESS INDICATOR      | SHARED_ADDRS_IND          | Mandatory          | VARCHAR2     |   1	|
		
			

	Scenario: Dropping an Address record that does not have a correlated PARTICIPANT_ID in MVI
		Given a valid VET360 person address BIO received from the CUF changelog
		When the changelog BIO PARTICIPANT_ID is NULL
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF

	Scenario: Accepting and not syncing a "pristine" Address record that originated from Corp  
		Given the following VET360 person address BIO received from the CUF changelog 
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser | orginatingSourceSys |
            | Corp        |                 | Today-180          | No                  |                    | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     | VICCPIAZ      | SHARE  - CADD       |
		When the changelog BIO txtAuditId matches to a CDC_Staging_Corp_Table txtAuditId
		And the record is active
		And addressLine1 equals ADDRS_ONE_TXT
		And addressLine2 equals ADDRS_TWO_TXT
		And addressLine3 equals ADDRS_THREE_TXT
		And cityName equals CITY_NM 
		And stateCode equals POSTAL_CD
		And zipCode5 equals ZIP_PREFIX_NBR
		Then the Adapter will drop record and sends "COMPLETED_SUCCESS" to CUF 

	Scenario: Updating one existing record in Corp
		Given the following VET360 person address BIO received from the CUF changelog
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser    | orginatingSourceSys |
            | VET360      |                 | Today              | No                  |                    | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     | KatherineJaneway | Vets.gov            |
        When the changelog BIO matches to a record in Corp address table in the database 
		And the record is active
		Then the Adapter will END_DT the address record as follows 
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT   | END_DT | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today-80   |Today   |  42 Wallaby Way| 		 	   |  	             | Sydney  |      	   | 33222	        | 			           |                       |        |   OH      |      	 USA    |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | KatherineJaneway  |  VETS360,Vets.gov |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "U"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"
		And inserts the following new record and sends "COMPLETED_SUCCESS" response to CUF
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today    |  42 Wallaby Way| 		 	     |  	           | Sydney  |      	 | 33222	      | 			         |                       |        |   OH      |      	 USA  |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | KatherineJaneway  |  VETS360,Vets.gov |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	
	
	Scenario: Updating multiple existing records in Corp
		Given the following VET360 person address BIO received from the CUF changelog
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser    | orginatingSourceSys |
            | VET360      |                 | Today              | No                  |                    | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     | KatherineJaneway | Vets.gov            |
		When the changelog BIO matches to two records in Corp address table in the database 
		And the records are active
		Then the Adapter will END_DT the address records as follows
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT   | END_DT | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today-90   |Today   |  42 Wallaby Dr | 		 	    |  	             | Sydney  |      	   | 33222	        | 			           |                       |        |   OH      |      	 USA    |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | KatherineJaneway  |  VETS360,Vets.gov |          |                |                |               |                      |                      |                        |  		N       |			
			| Mailing         	  |Today-80   |Today   |  42 Wallaby St | 		 	    |  	             | Sydney  |      	   | 33222	        | 			           |                       |        |   OH      |      	 USA    |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | KatherineJaneway  |  VETS360,Vets.gov |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "U"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	
		And inserts the following new record and sends "COMPLETED_SUCCESS" response to CUF
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today    |  42 Wallaby Way| 		 	     |  	           | Sydney  |      	 | 33222	      | 			         |                       |        |   OH      |      	 USA  |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | KatherineJaneway  |  VETS360,Vets.gov |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"		
		
	Scenario: Insert new VET360 address record into Corp where none exist
		Given the following VET360 person Email BIO received from the CUF changelog
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser    | orginatingSourceSys |
            | VET360      |                 | Today              | No                  |                    | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     | KatherineJaneway | Vets.gov            |
		When the changelog BIO does not match to a record in Corp Email table in the database 
		Then the Adapter inserts the following record and sends "COMPLETED_SUCCESS" response to CUF
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today    |  42 Wallaby Way| 		 	     |  	           | Sydney  |      	 | 33222	      | 			         |                       |        |   OH      |      	 USA  |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | KatherineJaneway  |  VETS360,Vets.gov |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	
	
	Scenario: Address BIO does not have sourceSysUser provenance field populated
		Given the following VET360 person Email BIO received from the CUF changelog
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser    | orginatingSourceSys |
            | VHAES       |                 | Today              | No                  |                    | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     |                  | VAMC-433            |
    	When sourceSysUser is NULL
 		Then the Adapter inserts the following record, populates JRN_EXTNL_USER_ID with value "UNK_USER" and sends "COMPLETED_SUCCESS" response to CUF
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today    |  42 Wallaby Way| 		 	     |  	           | Sydney  |      	 | 33222	      | 			         |                       |        |   OH      |      	 USA  |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | UNK_USER        |  VHAES,VAMC-433   |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	

	Scenario: Address BIO does not have orginatingSourceSys provenance field populated
		Given the following VET360 person address BIO received from the CUF changelog
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser    | orginatingSourceSys |
            | VHAES       |                 | Today              | No                  |                    | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     | KatherineJaneway |                     |
    	When orginatingSourceSys is NULL
 		Then the Adapter inserts the following record, appends "UNK_OSS" to JRN_EXTNL_KEY_TXT and sends "COMPLETED_SUCCESS" response to CUF
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today    |  42 Wallaby Way| 		 	     |  	           | Sydney  |      	 | 33222	      | 			         |                       |        |   OH      |      	 USA  |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | KatherineJaneway|  VHAES,UNK_OSS    |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	

	Scenario: Address BIO does not have orginatingSourceSys and sourceSysUser provenance fields populated
		Given the following VET360 person address BIO received from the CUF changelog
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser    | orginatingSourceSys |
            | VHAES       |                 | Today              | No                  |                    | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     |                  |                     |
    	When orginatingSourceSys is NULL
    	And sourceSystemUser is NULL
 		Then the Adapter inserts the following record, appends "UNK_OSS" to JRN_EXTNL_KEY_TXT, populates JRN_EXTNL_USER_ID with value "UNK_USER", and sends "COMPLETED_SUCCESS" response to CUF
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today    |  42 Wallaby Way| 		 	     |  	           | Sydney  |      	 | 33222	      | 			         |                       |        |   OH      |      	 USA  |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | UNK_USER        |  VHAES,UNK_OSS    |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	

	Scenario: End date one record 
		Given the following VET360 person address BIO received from the CUF changelog
			|sourceSystem | addressConfDate | effectiveStartDate | effectiveEndDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser    | orginatingSourceSys |
            | VET360      |                 | Today-90           | Today            | No                  |                    | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     | KatherineJaneway | Vets.gov            |
        When the changelog BIO matches to a record in Corp Address table in the database 
		And the record is active
		Then the Adapter will END_DT the record as follows and sends "COMPLETED_SUCCESS" response to CUF
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT | END_DT |ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today-90 |  Today |42 Wallaby Way| 		 	     |  	           | Sydney  |      	 | 33222	      | 			         |                       |        |   OH      |      	 USA  |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | KatherineJaneway  |  VETS360,Vets.gov |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "U"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	

	Scenario Outline: Address record "core" field from non-Corp source is identical to Corp record
		Given the following VET360 person address BIO received from the CUF changelog 
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser    | orginatingSourceSys |
            | VET360      |                 | Today              | No                  |    <vet360Pou>     | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     | KatherineJaneway | Vets.gov            |
		When the changelog BIO matches to a record in Corp Address table in the database
		And the record is active
		And the PTCPNT_ADDRS_TYPE_NM eqauls "<addressType>"
		And addressLine1 equals ADDRS_ONE_TXT
		And addressLine2 equals ADDRS_TWO_TXT
		And addressLine3 equals ADDRS_THREE_TXT
		And cityName equals CITY_NM 
		And stateCode equals POSTAL_CD
		And zipCode5 equals ZIP_PREFIX_NBR
		Then the Adapter will populate the END_DT field of the matching record with the changelog BIO effectiveStartDate value as follows
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT | END_DT | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today-3  |  Today | 42 Wallaby Way| 		 	     |  	           | Sydney  |      	 | 33222	      | 			         |                       |        |   OH      |      	 USA  |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | KatherineJaneway  |  VETS360,Vets.gov |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "U"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"			
		And commits the following new address record and sends "COMPLETED_SUCCESS" response to CUF
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today    |  42 Wallaby Way| 		 	     |  	           | Sydney  |      	 | 33222	      | 			         |                       |        |   OH      |      	 USA  |  	N   		|	   		     |                    |	                         | 		          |          |          |    22           |                       | KatherineJaneway  |  VETS360,Vets.gov |          |                |                |               |                      |                      |                        |  		N       |			
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	
         Examples:
		| addressType | vet360Pou     |
		| Residence   | Residential   |
		| Mailing     | Correspondence|
		
	Scenario: Military address from VET360
		Given the following VET360 person address BIO received from the CUF changelog 
		|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1    | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser    | orginatingSourceSys |
        | VET360      |                 | Today              | No                  | Military Overseas  | Correspondence| TF Awesome Tanks|   Box 555    |              | FPO      | AE        | 90215    |          |              |               | United States | US              | Today     | KatherineJaneway | Vets.gov            |
		When the addressType equals  "Military Overseas"
		Then the Adapter inserts the following record, maps cityName to MLTY_POST_OFFICE_TYPE_CD, maps stateName to MLTY_POSTAL_TYPE_CD, and sends "COMPLETED_SUCCESS" response to CUF
		|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT | ADDRS_ONE_TXT    | ADDRS_TWO_TXT  | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT |CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
		| Mailing         	  |Today    |  TF Awesome Tanks| 	Box 555	    |  	              |         |      	    | 90215          | 			         |                       |        |              |      	 USA  |  	N   		|	   		     |     AE               |	 FPO                        | 		          |          |          |    22           |                       | KatherineJaneway  |  VETS360,Vets.gov |          |                |                |               |                      |                      |                        |  		N       |			


