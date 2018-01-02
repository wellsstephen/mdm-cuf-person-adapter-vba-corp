##Drafted by Aramis Calderon (email: aramis.calderon@halfaker.com/ phone: 7608055923)
Feature: Adapt Corp Address BIO to VET360 Address data table
		As Department of Veterans Affairs Enterprise, I want to convert Address records in VBA Corp to VET360 Address record schema. 

	GoldenGate Assumptions:
	- Corp-CDC-Staging-Table filter will only provide an Address specific DB view/table.
	- Corp-CDC-Staging-Table will ONLY stage records where PTCPNT_ADDRS_TYPE_NM equals "Residence" or "Mailing".
    - Adapter will not check if a record is active and belongs to a living veteran without a fiduciary.	
    - Corp-CDC-Staging-Table will include Corp MVI staging table to make sure Adapter does not touch records awaiting synch to MVI.
    - Corp-CDC-Staging-Table will check SNTVTY_LEVEL table, in the SCRTY_LEVEL_TYPE_CD column if the Veteran is sensitivity level 8 or 9; not stage if it is.
    - Adapter will have to handle update transactions (END-DT active record, insert new) from Corp through the Corp-CDC-Staging-Table.
	
    Field Mappings:
	- Records from Corp are PTCPNT_ADDRS records with a PTCPNT_ADDRS_TYPE_NM equal to "Residence" or "Mailing"
	- VET360 record is created with effectiveStartDate matching Corp EFCTV_DT.
	- Corp ADDRS_ONE_TXT populates VET360 addressLine1 field.
	- Corp ADDRS_TWO_TXT populates VET360 addressLine2 field.
	- Corp ADDRS_THREE_TXT populates VET360 addressLine3 field.
	- Corp CITY_NM populates VET360 cityName field. 
	- Corp COUNTY_NM populates VET360 countyName field.
	- Corp ZIP_PREFIX_NBR populates VET360 zipCode5 field. 
	- Corp ZIP_FIRST_SUFFIX_NBR populates VET360 zipCode4 field.
	- Corp POSTAL_CD populates VET360 stateCode field.
	- Corp CNTRY_TYPE_NM populates VET360 countryName field.
	- Corp BAD_ADDRS_IND populates VET360 badAddressIndicator field; post-IOC.
	- Corp FRGN_POSTAL_CD populates VET360 intPostalCode field.
	- Corp PRVNC_NM populates VET360 provinceName field.
	- Corp EFCTV_DT populates VET360 effectiveStartDate field.
	- Corp JRN_DT populates VET360 sourceDate field.
	- Corp JRN_OBJ_ID populates VET360 orginatingSourceSys field.
	- Corp JRN_USER_ID populates VET360 sourceSysUser field.
	- VET360 sourceSystem value will be derived from header data.
		
 	Background: Veteran address record from Corp PTCPNT_ADDRS table to VET360 adapted table.
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
		
			
	Scenario: Drop Corp Address record if it has no Address
		Given the following person address DIO received from the Corp-CDC-Staging-Table
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT   | ADDRS_ONE_TXT | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT         | MLTY_POSTAL_TYPE_CD        | MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | JRN_DT    | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM | CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			|Mailing     	      |Today-10   |               | 		 	  |      		    | 		  |      	  |		           | 			          |                       |        |           |      	       |  			   |	            		 |	                          |				             | 		         |          |          |   Today-10|  301        |VHALASFINKED |  I                 | secauser   |  4422           |                       |                   |                   |                     |           |                |                |               |                      |                      |                        |  		N        |			
		When ADDRS_ONE_TXT is null
		And ADDRS_TWO_TXT is null
		And ADDRS_THREE_TXT is null
		Then the Adapter will drop record and send "COMPLETED_NOOP" to Corp-CDC-Staging-Table
	
	Scenario Outline: Corp Address Record of an accepted Type has a valid Address 
		Given the following person address DIO received from the Corp-CDC-Staging-Table
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT   | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | JRN_DT    | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID    | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM | CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| <addressType >	  |Today-180  |  42 Wallaby Way| 		 	   |  	             | Sydney  |      	   | 33222	        | 			           |                       |        |   OH      |      	 USA    |  	N   		|	   		     |                    |	                         | 		          |          |          | Today-21  |  325        |VICCPIAZ     |  U                 | SHARE  - CADD |    22           |                       |                   |                   |                     |           |                |                |               |                      |                      |                        |  		N       |			
		When PTCPNT_ADDRS_TYPE_NM is "<addressType>"
		Then the Adapter will convert the Email to the following VET360 BIO and send through Maintenance-Endpoint which will return a "RECEIVED" response to Corp-CDC-Staging-Table
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser | orginatingSourceSys |
            | Corp        |                 | Today              | No                  |                    | <vet360Pou>| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today- 21 | VICCPIAZ      | SHARE  - CADD       |
         Examples:
		| addressType | vet360Pou     |
		| Residence   | Residential   |
		| Mailing     | Correspondence|

	Scenario: Updating an address record in VET360 
		Given the following person address DIO received from the Corp-CDC-Staging-Table
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT   | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | JRN_DT    | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID    | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM | CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today      |  42 Wallaby Way| 		 	   |  	             | Sydney  |      	   | 33222	        | 			           |                       |        |   OH      |      	 USA    |  	N   		|	   		     |                    |	                         | 		          |          |          | Today     |  325        |VICCPIAZ     |  I                 | SHARE  - CADD |    22           |                       |                   |                   |                     |           |                |                |               |                      |                      |                        |  		N       |			
		When Address record DIO PTCPNT_ID received from the Corp-CDC-Staging-Table correlates to VET360Id 
		Then the Adapter will convert the Address to the following VET360 BIO, does not populate effectiveStartDate with EFCTV_DT, and send through Maintenance-Endpoint which will return "RECEIVED" to Corp-CDC-Staging-Table
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser | orginatingSourceSys |
            | Corp        |                 | Today-180          | No                  |                    | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     | VICCPIAZ      | SHARE  - CADD       |
		
	Scenario: End-date an Address record in VET360 
		Given the following person address DIO received from the Corp-CDC-Staging-Table
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT   | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | JRN_DT    | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID    | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM | CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing         	  |Today      |  42 Wallaby Way| 		 	   |  	             | Sydney  |      	   | 33222	        | 			           |                       | Today  |   OH      |      	 USA    |  	N   		|	   		     |                    |	                         | 		          |          |          | Today     |  325        |VICCPIAZ     |  I                 | SHARE  - CADD |    22           |                       |                   |                   |                     |           |                |                |               |                      |                      |                        |  		N       |			
		When Address record DIO PTCPNT_ID received from the Corp-CDC-Staging-Table correlates to VET360Id 
		And has an END_DT not NULL
		Then the Adapter will convert the Address to the following VET360 BIO and send through Maintenance-Endpoint which will return "RECEIVED" to Corp-CDC-Staging-Table
			|sourceSystem | addressConfDate | effectiveStartDate | effectiveEndDate  | badAddressIndicator | addressType 		| addressPOU    | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser | orginatingSourceSys |
            | Corp        |                 | Today-180          | Today             |  No                 |                    | Correspondence| 42 Wallaby Way|              |              | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     | VICCPIAZ      | SHARE  - CADD       |

	Scenario: End-date an Address record with a different address value in VET360 
		Given the following person address DIO received from the Corp-CDC-Staging-Table
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT   | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | JRN_DT    | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID    | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM | CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Residence       	  |Today      |  41 Wallaby Way| 		 	   |  	             | Sydney  |      	   | 33222	        | 			           |                       |  Today |   OH      |      	 USA    |  	N   		|	   		     |                    |	                         | 		          |          |          | Today     |  325        |VICCPIAZ     |  I                 | SHARE  - CADD |    22           |                       |                   |                   |                     |           |                |                |               |                      |                      |                        |  		N       |			
		When Email record DIO PTCPNT_ID received from the Corp-CDC-Staging-Table correlates to VET360Id 
		And the ADDRS_ONE_TXT does not equal to addressLine1
		Then the Adapter will convert the Address to the following VET360 BIO and send through Maintenance-Endpoint which will return "RECEIVED_ERROR_QUEUE" to Corp-CDC-Staging-Table
			|sourceSystem | addressConfDate | effectiveStartDate | effectiveEndDate  | badAddressIndicator | addressType 		| addressPOU  | addressLine1  | addressLine2 | addressLine3 | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser | orginatingSourceSys |
            | Corp        |                 | Today-180          | Today             |  No                 |                    | Residential   | 41 Wallaby Way|            |            | Sydney   | OH        | 33222    |          |              |               | United States | US              | Today     | VICCPIAZ      | SHARE  - CADD       |
			
	Scenario: Military address sent to VET360
		Given the following person address DIO received from the Corp-CDC-Staging-Table
			|PTCPNT_ADDRS_TYPE_NM |EFCTV_DT   | ADDRS_ONE_TXT  | ADDRS_TWO_TXT | ADDRS_THREE_TXT | CITY_NM | COUNTY_NM | ZIP_PREFIX_NBR | ZIP_FIRST_SUFFIX_NBR | ZIP_SECOND_SUFFIX_NBR | END_DT | POSTAL_CD | CNTRY_TYPE_NM | BAD_ADDRS_IND | EMAIL_ADDRS_TXT| MLTY_POSTAL_TYPE_CD| MLTY_POST_OFFICE_TYPE_CD | FRGN_POSTAL_CD | PRVNC_NM | TRTRY_NM | JRN_DT    | JRN_LCTN_ID | JRN_USER_ID | JRN_STATUS_TYPE_CD | JRN_OBJ_ID    | PTCPNT_ADDRS_ID | GROUP1_VERIFD_TYPE_CD | JRN_EXTNL_USER_ID | JRN_EXTNL_KEY_TXT | JRN_EXTNL_APPLCN_NM | CREATE_DT | CREATE_LCTN_ID | CREATE_USER_ID | CREATE_OBJ_ID | CREATE_EXTNL_USER_ID | CREATE_EXTNL_KEY_TXT | CREATE_EXTNL_APPLCN_NM | SHARED_ADDRS_IND | 
			| Mailing       	  |Today      |  TF Awesome    | Unit 3500	   |  	Stuttgart    |         |      	   |     	        | 			           |                       |        |           |      	 USA    |  	N   		|	   		     |     AE             |	  FPO                    | 		          |          |          | Today     |  325        |VICCPIAZ     |  I                 | SHARE  - CADD |    22           |                       |                   |                   |                     |           |                |                |               |                      |                      |                        |  		N       |			
 		When MLTY_POSTAL_TYPE_CD is not Null
 		And MLTY_POST_OFFICE_TYPE_CD is not Null
		Then the Adapter will convert the Address to the following VET360 BIO, map MLTY_POSTAL_TYPE_CD to stateCode and MLTY_POST_OFFICE_TYPE_CD to cityName, and send through Maintenance-Endpoint which will return "RECEIVED_ERROR_QUEUE" to Corp-CDC-Staging-Table
			|sourceSystem | addressConfDate | effectiveStartDate | badAddressIndicator | addressType 		| addressPOU       | addressLine1  | addressLine2 | addressLine3      | cityName | stateCode | zipCode5 | zipCode4 | provinceName | intPostalCode | countryName   | countryCodeFIPS | soureDate | sourceSysUser | orginatingSourceSys |
            | Corp        |                 | Today              |  No                 |                    | Correspondence   | TF Awesome    |  Unit 3500   |         Stuttgart |  FPO     |   AE      |          |          |              |               | United States | US              | Today     | VICCPIAZ      | SHARE  - CADD       |
			
			