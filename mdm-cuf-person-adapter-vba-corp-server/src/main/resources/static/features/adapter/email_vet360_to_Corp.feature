##Drafted by Aramis Calderon (email: aramis.calderon@halfaker.com/ phone: 7608055923)##
Feature: Adapt VET360 Email BIO to Corp Address data table
		As Department of Veterans Affairs Enterprise, I want to convert Email Address records in VET360 to VBA Corp Email records schema. 

	Constraints:
	- Email addresses in the VBA Corp are stored in physical address Table (PTCPNT_ADDRS). 
	
	Assumptions:
	- Record coming from VET360 is a Veteran.
	- Veteran records wih 2 PARTICIPANT_IDs will be sent to the Error Queue and never populated in the changelog.
	- Any change pushed to Corp by VET360 is already validated as an Alive Veteran.
	- Adapter will be able to query existing records in Corp
	- Contact information change pushed out to Corp that matches records will be End-Dated even if the 
		core fields (e.g. area number, phone number, extension) are identical thus updating the provenance fields (i.e. the mapped JRN_XX columns)
	
    Field Mappings:
	- Corp record is created with EFCTV_DT matching VET360 effectiveStartDate .
	- Existing Corp email record's END_DT is set to VET360 effectiveStartDate.
	- VET360 emailAddressText populates Corp EMAIL_ADDRS_TXT field.
	- VET360 effectiveStartDate populates Corp EFCTV_DT field.
	- VET360 sourceDate populates Corp JRN_DT field.
	- VET360 orginatingSourceSys populates Corp JRN_OBJ_ID field.
	- VET360 sourceSysUser populates Corp JRN_USER_ID field.
	- VET360 sourceSystem populates Corp JRN_EXTNL_APPLCN_NM field.
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
			| sourceSystem        | ADR              |
			| orginatingSourceSys | VET360            |
			| sourceSysUser       | Jeff             |
			| sourceDate          | Today            |

			
	#1
	Scenario: Dropping an Email record that does not have a PARTICIPANT_ID in MVI
		Given a valid Vet360 person Email BIO received from the CUF changelog
		When the changelog BIO PARTICIPANT_ID is NULL
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF#Pending Michelle

	Scenario: Dropping an Email record that does not have a PERSON record in Corp matching the corralated PARTICIPANT_ID 
		Given a valid Vet360 person Email BIO received from the CUF changelog
		When the Corp PERSON record does not exist for the given changelog PARTICIPANT_ID 
		Then the Adapter will drop record and sends "COMPLETED_NOOP" to CUF		
		
	Scenario: Updating one existing records in Corp
		Given the following Vet360 person Email BIO received from the CUF changelog
			|sourceSystem | emailAddressText       | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|
			| VETSGOV     | megadeath2@oldies.com  | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         | Jeff Watermelon |   1   |
        When the changelog BIO has PTCPNT_ID equal to one Corp record in PTCPNT_ADDRS table
		And the effectiveStartDate is greater than or equal to EFCTV_DT or END_DT is NULL
		Then the Adapter will populate the following Email record with the END_DT equal to the effectiveStartDate value
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT     | EFCTV_DT | END_DT       | JRN_LCTN_ID         | 
			| EMAIL         	    |megadeath1@oldies.com | Today-90 | Today        |	<CorpProvided>	 | 
		And the JRN_STATUS_TYPE_CD = "U"	
		And the JRN_USER_ID = sourceSysUser
		And the JRN_EXTNL_APPLCN_NM = SourceSystem
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = orginatingSourceSys
		And commits the following new record in PTCPNT_ADDRS with a PTCPNT_ADDRS_TYPE_NM value of EMAIL and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT       | EFCTV_DT |  JRN_LCTN_ID         | 
			| EMAIL         	    |megadeath2@oldies.com | Today    |  	<CorpProvided>	 | 
		And the JRN_STATUS_TYPE_CD = "I"	
		And the JRN_USER_ID = sourceSysUser
		And the JRN_EXTNL_APPLCN_NM = SourceSystem
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = orginatingSourceSys		
	
	Scenario: Updating multiple existing records in Corp
		Given the following Vet360 person Email BIO received from the CUF changelog
        	|sourceSystem | emailAddressText       | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|
			| VETSGOV     | Pantera3@oldies.com    | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         | Jeff Apleegate	 |   1   |
		When the changelog BIO has PTCPNT_ID equal to two Corp records in PTCPNT_ADDRS table
		And the effectiveStartDate is greater than or equal to EFCTV_DT or END_DT is NULL
		Then the Adapter will populate the following Email records with the END_DT equal to the effectiveStartDate value#show matching Corp records end-date
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT     | EFCTV_DT | END_DT       | JRN_LCTN_ID         | 
			| EMAIL         	    |Pantera1@oldies.com | Today-90 | Today        |	<CorpProvided>	 | 
			| EMAIL         	    |Pantera2@oldies.com | Today-30 | Today        |	<CorpProvided>	 | 
		And the JRN_STATUS_TYPE_CD = "U"	
		And the JRN_USER_ID = sourceSysUser
		And the JRN_EXTNL_APPLCN_NM = SourceSystem
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = orginatingSourceSys
		And commits the following new record in PTCPNT_ADDRS with a PTCPNT_ADDRS_TYPE_NM value of EMAIL and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT       | EFCTV_DT |  JRN_LCTN_ID         | 
			| EMAIL         	    |Pantera3@oldies.com | Today    |  	<CorpProvided>	 | 
		And the JRN_STATUS_TYPE_CD = "I"	
		And the JRN_USER_ID = sourceSysUser
		And the JRN_EXTNL_APPLCN_NM = SourceSystem
	    And the JRN_DT = sourceDate
		And the JRN_OBJ_ID = orginatingSourceSys		
		
	Scenario: Insert new Vet360 email record into Corp
		Given the following Vet360 person Email BIO received from the CUF changelog
        	|sourceSystem | emailAddressText       | effectiveStartDate |sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|
			| VETSGOV     | everlast@oldies.com    | Today              | Today       | Today            | NO_KNOWN_PROBLEM | True         | James Hetfield  |   1   |
		When the changelog BIO has PTCPNT_ID not equal Corp record in PTCPNT_ADDRS table
		Then the Adapter will insert the following record and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT       | EFCTV_DT |  JRN_LCTN_ID         |  
			| EMAIL         	    | everlast@oldies.com  | Today    |  	<CorpProvided>	 | 
		And the JRN_STATUS_TYPE_CD = "I"	
		And the JRN_USER_ID = sourceSysUser
		And the JRN_EXTNL_APPLCN_NM = SourceSystem
	    And the JRN_DT = sourceDate
	    And the JRN_OBJ_ID = orginatingSourceSys
	
	Scenario: Veteran only has a work email on record and retires
		Given the following Vet360 person Email BIO received from the CUF changelog
        	|sourceSystem | emailAddressText       | effectiveStartDate | effectiveEndDate|sourceDate   | confirmationDate | emailStatusCode  | emailPermInd |sourceSystemUser |emailId|
			| VETSGOV     | Fade2Black@oldies.com  | Today-30           | Today           | Today       | Today            | NO_KNOWN_PROBLEM | False        | Bob Sieger      |   2   |
		When the changelog BIO has PTCPNT_ID equal to a Corp record in PTCPNT_ADDRS table
		And PTCPNT_ADDRS_TYPE_NM equals "<EMAIL>"
		And the changelog BIO effectiveStartDate is greater than or equal to EFCTV_DT or END_DT is NULL
		Then the Adapter will populate the END_DT field with the effectiveEndDate and sends "COMPLETED_SUCCESS" response to CUF
			| PTCPNT_ADDRS_TYPE_NM  |EMAIL_ADDRS_TXT         | EFCTV_DT |  END_DT    |   JRN_LCTN_ID         |  
			| EMAIL         	    | Fade2Black@oldies.com  | Today-30 | Today      | <CorpProvided>	 | 
		And the JRN_STATUS_TYPE_CD = "U"	
		And the JRN_USER_ID = sourceSysUser
		And the JRN_EXTNL_APPLCN_NM = SourceSystem
	    And the JRN_DT = sourceDate
	    And the JRN_OBJ_ID = orginatingSourceSys

			