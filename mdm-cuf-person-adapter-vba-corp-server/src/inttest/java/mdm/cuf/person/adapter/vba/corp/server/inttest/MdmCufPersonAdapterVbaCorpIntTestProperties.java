package mdm.cuf.person.adapter.vba.corp.server.inttest;

import org.springframework.beans.factory.annotation.Value;

import mdm.cuf.core.server.AbstractMdmCufCoreServerProperties;

public class MdmCufPersonAdapterVbaCorpIntTestProperties extends AbstractMdmCufCoreServerProperties {

    /** The Constant serialVersionUID. */
    private static final long serialVersionUID = 2471797857757651915L;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.baseUrl}")
    private String baseUrl;
    
    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.personPost}")
    private String personPost;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.personPut}")
    private String personPut;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.personGet}")
    private String personGet;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.personGetStatus}")
    private String personGetStatus;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.pathToExcel}")
    private String pathToExcel;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.personMaintenance}")
    private String personMaintenance;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.phonePost}")
    private String phonePost;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.phonePut}")
    private String phonePut;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.phoneGet}")
    private String phoneGet;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.phoneGetAll}")
    private String phoneGetAll;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.phoneGetHistory}")
    private String phoneGetHistory;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.phoneGetStatus}")
    private String phoneGetStatus;
    
    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.emailPost}")
    private String emailPost;

    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.emailPut}")
    private String emailPut;
    
    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.emailGetCurrent}")
    private String emailGetCurrent;
    
    @Value("${mdm-cuf-person-adapter-vbacorp-inttest.addressPut}")
    private String addressPut;
    
//    @Value("${mdm-cuf-person-inttest.addressGetCurrent}")
//    private String addressGetCurrent;
//    
//    public String getAddressGetCurrent() {
//		return addressGetCurrent;
//	}
//
//	public void setAddressGetCurrent(String addressGetCurrent) {
//		this.addressGetCurrent = addressGetCurrent;
//	}

	public String getAddressPut() {
		return addressPut;
	}

	public void setAddressPut(String addressPut) {
		this.addressPut = addressPut;
	}

	public String getEmailGetCurrent() {
		return emailGetCurrent;
	}

	public void setEmailGetCurrent(String emailGetCurrent) {
		this.emailGetCurrent = emailGetCurrent;
	}
	
	@Value("${mdm-cuf-person-adapter-vbacorp-inttest.emailGetStatus}")
    private String emailGetStatus;

	public String getEmailGetStatus() {
		return emailGetStatus;
	}

	public void setEmailGetStatus(String emailGetStatus) {
		this.emailGetStatus = emailGetStatus;
	}

	@Value("${mdm-cuf-person-adapter-vbacorp-inttest.personChangeLogGetStatus}")
    private String personChangeLogGetStatus;
    
    public String getPersonChangeLogGetStatus() {
		return personChangeLogGetStatus;
	}

	public void setPersonChangeLogGetStatus(String personChangeLogGetStatus) {
		this.personChangeLogGetStatus = personChangeLogGetStatus;
	}

	public String getBaseUrl() {
        return baseUrl;
    }

    public void setBaseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public String getPersonPost() {
        return personPost;
    }

    public void setPersonPost(String personPost) {
        this.personPost = personPost;
    }

    public String getPersonPut() {
        return personPut;
    }

    public void setPersonPut(String personPut) {
        this.personPut = personPut;
    }

    public String getPersonGet() {
        return personGet;
    }

    public void setPersonGet(String personGet) {
        this.personGet = personGet;
    }

    public String getPersonGetStatus() {
        return personGetStatus;
    }

    public void setPersonGetStatus(String personGetStatus) {
        this.personGetStatus = personGetStatus;
    }

    public String getPathToExcel() {
        return pathToExcel;
    }

    public void setPathToExcel(String pathToExcel) {
        this.pathToExcel = pathToExcel;
    }

    public String getPersonMaintenance() {
        return personMaintenance;
    }

    public void setPersonMaintenance(String personMaintenance) {
        this.personMaintenance = personMaintenance;
    }

    public String getPhonePost() {
        return phonePost;
    }

    public void setPhonePost(String phonePost) {
        this.phonePost = phonePost;
    }

    public String getPhonePut() {
        return phonePut;
    }

    public void setPhonePut(String phonePut) {
        this.phonePut = phonePut;
    }

    public String getPhoneGet() {
        return phoneGet;
    }

    public void setPhoneGet(String phoneGet) {
        this.phoneGet = phoneGet;
    }

    public String getPhoneGetAll() {
        return phoneGetAll;
    }

    public void setPhoneGetAll(String phoneGetAll) {
        this.phoneGetAll = phoneGetAll;
    }

    public String getPhoneGetHistory() {
        return phoneGetHistory;
    }

    public void setPhoneGetHistory(String phoneGetHistory) {
        this.phoneGetHistory = phoneGetHistory;
    }

    public String getPhoneGetStatus() {
        return phoneGetStatus;
    }

    public void setPhoneGetStatus(String phoneGetStatus) {
        this.phoneGetStatus = phoneGetStatus;
    }

    public String getEmailPost() {
        return emailPost;
    }

    public void setEmailPost(String emailPost) {
        this.emailPost = emailPost;
    }

    public String getEmailPut() {
        return emailPut;
    }

    public void setEmailPut(String emailPut) {
        this.emailPut = emailPut;
    }
    
}