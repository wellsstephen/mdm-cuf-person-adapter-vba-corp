##Drafted by Aramis Calderon (email: aramis.calderon@halfaker.com/ phone: 7608055923)
Feature: Adapt VET360 Email BIO to Corp Address data table
		As Department of Veterans Affairs Enterprise, I want to convert Email Address records in VET360 to VBA Corp Email records schema. 

	Definition of Terms
    - Matching: Returned PTCPNT_ID from MVI call equals the PTCPNT_ID of the destination table (PTCPNT_PHONE or PTCPNT_ADDRS)
    - Active: Current date falling between the EFCTV_DT and END_DT (or END_DT is null)
    - Delete: END_DT of Corp record will be equal to VET360 effectiveEndDate
    - Cleansing: Vet360 CUF has modified the data that doesn't fundamentally change the contact info record 
    - Pristine: No change was made by the Vet360 CUF

	Constraints:
	- Email addresses in the VBA Corp are stored in PTCPNT_ADDRS Table. 
	
	Assumptions:
	- Veteran records with 2 PARTICIPANT_IDs will be sent to the Error Queue and never populated in the changelog.
	- Any change pushed to Corp by VET360 is already validated as an Alive Veteran.
	- Adapter will be able to query existing records in Corp
	- If no Corp correlated ID/participant ID is present in the CUF change log queue message then we will drop the change and post back to the CUF a COMPLETED_NOOP
	- Contact information change pushed out to Corp that matches records will be End-Dated even if the 
		core fields (e.g. email text) are identical thus updating the provenance fields (i.e. the mapped JRN_XX columns)
    - Adapter has to check SNTVTY_LEVEL table, in the SCRTY_LEVEL_TYPE_CD column if the Veteran is sensitivity level 8 or 9; drop if it is, COMPLETED_NOOP.
	
    Field Mappings:
	- Corp record is created with EFCTV_DT matching VET360 effectiveStartDate .
	- Existing Corp email record's END_DT is set to VET360 effectiveStartDate.
	- VET360 emailAddressText populates Corp EMAIL_ADDRS_TXT field.
	- VET360 effectiveStartDate populates Corp EFCTV_DT field.
	- VET360 sourceDate populates Corp JRN_DT field.
	- JRN_EXTNL_APPLCN_NM will have "vet360adapter" in the field.
	- VET360 sourceSysUser populates JRN_EXTNL_USER_ID.
	- JRN_OBJ_ID will have application name + action (e.g. “VET360PHONE”, “VET360AddressUp”, “VET360CONTACTUPDATE”). 
	- JRN_USER_ID will have "VET360SYSACCT" in the field.
    - VET360 sourceSystem, orginatingSourceSys, and sourceSysUser populates comma separated Corp JRN_EXTNL_KEY_TXT field; in that order.
	- Corp JRN_LCTN_ID value will be derived from service.
	- Corp JRN_STATUS_TYPE_CD value will be derived from type of transaction (logical delete/update or new record).
		
 	Background: Veteran phone record from Corp PTCPNT_ADDRS table to VET360 adapted table.
		Given VET360 BIO Schema for email
			| Attribute Name                    | Coded Value            | Mandatory/Optional | Type (length)   | Length | Standard | common/core | IOC |
			| Effective Start Date              | effectiveStartDate     | Mandatory          | Date            |        | ISO 8601 |             |		|
			| Effective End Date                | effectiveEndDate       | Optional           | Date            |        | ISO 8601 |             |		|
			| Email Address                     | emailAddressText       | Mandatory          | String          | 255    | none     |             |		|
			| Email Permission To Use Indicator | emailPermInd           | Optional           | Boolean         |        | none     |             |		|
			| Email Delivery Status Code        | emailStatusCode        | Optional           | Enumerated List |        | none     |             |		|
			| Confirmation Date                 | emailConfDate          | Optional           | Date            |        | ISO 8601 |             |		|
			| Source System                     | sourceSystem           | Optional           | String          | 255    | none     | core        |		|
			| Originating Source System         | orginatingSourceSys    | Optional           | String          | 255    | none     | core        |		|
			| Source System User                | sourceSysUser          | Optional           | String          | 255    | none     | core        |		|
			| Source Date                       | sourceDate             | Mandatory          | Date/Time (GMT) |        | ISO 8601 | core        |		|
			| Email ID                          | emailId				 | Optional           | String          |        | none     |             |		|
		
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
			
		Given the system has defined a valid Email
			| Attrbute Name       | Value            |
			| effectiveStartDate  | Today            |
			| effectiveEndDate    | null             |
			| emailAddressText    | jdoe@gmail.com   |
			| emailPermInd        | true             |
			| emailStatusCode     | NO_KNOWN_PROBLEM |
			| emailConfDate       | Today            |
			| sourceSystem        | VHAES              |
			| orginatingSourceSys | VET360           |
			| sourceSysUser       | Jeff             |
			| sourceDate          | Today            |


	Scenario: Dropping an Email record that does not have a correlated PARTICIPANT_ID in MVI
		Given a valid VET360 person Email BIO received from the CUF changelog
		When the changelog BIO PARTICIPANT_ID is NULL
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF

	Scenario: Dropping an Email record that has sensitivity level of 8 or 9 
		Given a valid VET360 person Email BIO received from the CUF changelog
		When the changelog BIO PARTICIPANT_ID is correlates to SCRTY_LEVEL_TYPE_CD of 8 or 9
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF

	Scenario: Accepting and not syncing a "pristine" Email record that originated from Corp  
		Given the following VET360 person email BIO received from the CUF changelog 
			|sourceSystem | emailAddressText         | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|orginatingSourceSys|
			| Corp        | BlackSabbath@oldies.com  | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         | VSCLYARB        |   9   | VBMS  - CEST		 |
		When the changelog BIO txtAuditId matches to a CDC_Staging_Corp_Table txtAuditId
		And the record is active
		And the PTCPNT_ADDRS_TYPE_NM equals "<EMAIL>"
		And emailAddressText equals EMAIL_ADDRS_TXT
		Then the Adapter will drop record and sends "COMPLETED_SUCCESS" to CUF 

	Scenario: Updating one existing record in Corp
		Given the following VET360 person Email BIO received from the CUF changelog
			|sourceSystem | emailAddressText       | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|orginatingSourceSys|
			| VETS360     | megadeath2@oldies.com  | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         | Jeff Watermelon |   1   | Vets.gov			 |
        When the changelog BIO matches to a record in Corp Email table in the database 
		And the record is active
		Then the Adapter will END_DT the following Email record 
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT     | EFCTV_DT   | END_DT | JRN_EXTNL_KEY_TXT   | JRN_EXTNL_USER_ID |
			| EMAIL         	    |megadeath1@oldies.com | Today-90 | Today  |VETS360,Vets.gov  	 | Jeff Watermelon   |
		And the JRN_STATUS_TYPE_CD = "U"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"
		And inserts the following new record and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT       | EFCTV_DT |  JRN_EXTNL_KEY_TXT| JRN_EXTNL_USER_ID |
			| EMAIL         	    |megadeath2@oldies.com | Today    |  VETS360,Vets.gov | Jeff Watermelon   |
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	
	
	Scenario: Updating multiple existing records in Corp
		Given the following VET360 person Email BIO received from the CUF changelog
        	|sourceSystem | emailAddressText       | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|orginatingSourceSys|
			| VETS360     | Pantera3@oldies.com    | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         | Jeff Apleegate	 |   2   |Vets.gov           |
		When the changelog BIO matches to two records in Corp Email table in the database 
		And the records are active
		Then the Adapter will END_DT the following Email records
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT     | EFCTV_DT | END_DT |  JRN_EXTNL_KEY_TXT| JRN_EXTNL_USER_ID |
			| EMAIL         	    |Pantera1@oldies.com | Today-90 | Today  |	VETS360,Vets.gov | Jeff Apleegate    |
			| EMAIL         	    |Pantera2@oldies.com | Today-30 | Today  |	VETS360,Vets.gov | Jeff Apleegate    |
		And the JRN_STATUS_TYPE_CD = "U"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	
		And inserts the following new record and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT       | EFCTV_DT |  JRN_EXTNL_KEY_TXT | JRN_EXTNL_USER_ID |
			| EMAIL         	    |Pantera3@oldies.com | Today    |  	VETS360,Vets.gov,  | Jeff Apleegate    |
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"		
		
	Scenario: Insert new VET360 email record into Corp where none exist
		Given the following VET360 person Email BIO received from the CUF changelog
        	|sourceSystem | emailAddressText       | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|orginatingSourceSys|
			| VETS360     | everlast@oldies.com    | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         | James Hetfield  |   3   |Vets.gov           |
		When the changelog BIO does not match to a record in Corp Email table in the database 
		Then the Adapter inserts the following record and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT       | EFCTV_DT |   JRN_EXTNL_KEY_TXT | JRN_EXTNL_USER_ID |
			| EMAIL         	    | everlast@oldies.com  | Today    |  VETS360,Vets.gov   | James Hetfield|
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	
	
	Scenario: Email BIO does not have sourceSysUser provenance field populated
		Given the following VET360 person Email BIO received from the CUF changelog
        	|sourceSystem | emailAddressText       | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|orginatingSourceSys|
			| VHAES         | metallica@oldies.com   | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         |                 |   5   |VAMC-433           |
    	When sourceSysUser is NULL
 		Then the Adapter inserts the following record, populates JRN_EXTNL_USER_ID with value "UNK_USER" and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT       | EFCTV_DT |   JRN_EXTNL_KEY_TXT |  JRN_EXTNL_USER_ID |
			| EMAIL         	    | metallic@oldies.com  | Today    |  VHAES,VAMC-433       | UNK_USER           | 
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	

	Scenario: Email BIO does not have orginatingSourceSys provenance field populated
		Given the following VET360 person Email BIO received from the CUF changelog
        	|sourceSystem | emailAddressText       | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|orginatingSourceSys|
			| VETS360     | metallic@oldies.com    | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         | Jason           |   6   |                   |
    	When orginatingSourceSys is NULL
 		Then the Adapter inserts the following record, appends "UNK_OSS" to JRN_EXTNL_KEY_TXT and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT       | EFCTV_DT |   JRN_EXTNL_KEY_TXT |  JRN_EXTNL_USER_ID |
			| EMAIL         	    | metallic@oldies.com  | Today    |  VETS360,UNK_OSS    |  Jason             |
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	

	Scenario: Email BIO does not have orginatingSourceSys and sourceSysUser provenance fields populated
		Given the following VET360 person Email BIO received from the CUF changelog
        	|sourceSystem | emailAddressText       | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|orginatingSourceSys|
			| VETS360         | metallic@oldies.com    | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         |                 |   6   |                   |
    	When orginatingSourceSys is NULL
    	And sourceSystemUser is NULL
 		Then the Adapter inserts the following record, appends "UNK_OSS" to JRN_EXTNL_KEY_TXT, populates JRN_EXTNL_USER_ID with value "UNK_USER", and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT       | EFCTV_DT |   JRN_EXTNL_KEY_TXT |  JRN_EXTNL_USER_ID |
			| EMAIL         	    | metallic@oldies.com  | Today    |  VETS360,UNK_OSS        | UNK_USER           |
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	

	Scenario: End date email on record 
		Given the following VET360 person Email BIO received from the CUF changelog
        	|sourceSystem | emailAddressText       | effectiveStartDate | effectiveEndDate|sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|orginatingSourceSys|
			| VETS360     | Fade2Black@oldies.com  | Today-30           | Today           | Today       | Today            | NO_KNOWN_PROBLEM | False        | Bob Sieger      |   4   | Vets.gov          |
        When the changelog BIO matches to a record in Corp Email table in the database 
		And the record is active
		Then the Adapter will END_DT the record as follows and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT         | EFCTV_DT |  END_DT    |    JRN_EXTNL_KEY_TXT        | JRN_EXTNL_USER_ID|
			| EMAIL         	    | Fade2Black@oldies.com  | Today-30 | Today      | VETS360,Vets.gov           | Bob Sieger |
		And the JRN_STATUS_TYPE_CD = "U"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	

	Scenario: Email record "core" field from non-Corp source is identical to Corp record
		Given the following VET360 person Email BIO received from the CUF changelog 
			|sourceSystem | emailAddressText          | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|orginatingSourceSys|
			| VETS360     | BlackSabbath2@oldies.com  | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         | Ozzy O          |   10   | Vets.gov          |
		When the changelog BIO matches to a record in Corp Address table in the database
		And the record is active
		And the PTCPNT_ADDRS_TYPE_NM eqauls "<EMAIL>"
		And emailAddressText equals EMAIL_ADDRS_TXT
		Then the Adapter will populate the END_DT field of the matching record with the changelog BIO effectiveStartDate value as follows
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT            | EFCTV_DT |  END_DT    |    JRN_EXTNL_KEY_TXT                | JRN_EXTNL_USER_ID|
			| EMAIL         	    | BlackSabbath2@oldies.com  | Today-30 | Today      | VETS360,Vets.gov                    |  Ozzy O     |
		And the JRN_STATUS_TYPE_CD = "U"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"			And commits the following new Email record and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT            | EFCTV_DT |  END_DT    |    JRN_EXTNL_KEY_TXT                |  JRN_EXTNL_USER_ID|
			| EMAIL         	    | BlackSabbath2@oldies.com  | Today    |            | VETS360,Vets.gov                    |  Ozzy O     |
		And the JRN_STATUS_TYPE_CD = "I"	
		And JRN_LCTN_ID = "281"
		And the JRN_USER_ID = "VET360SYSACCT"
		And the JRN_EXTNL_APPLCN_NM = "vet360adapter"
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = "VET360AddressUp"	

		