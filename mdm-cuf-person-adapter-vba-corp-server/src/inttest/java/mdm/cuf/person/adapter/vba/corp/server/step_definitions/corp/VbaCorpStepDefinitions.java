package mdm.cuf.person.adapter.vba.corp.server.step_definitions.corp;

import static org.junit.Assert.assertEquals;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.jayway.restassured.path.json.JsonPath;
import com.jayway.restassured.response.Response;

import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import mdm.cuf.core.api.CufResponse;
import mdm.cuf.core.api.CufStatusResponse;
import mdm.cuf.core.api.CufTxStatus;
import mdm.cuf.core.server.logging.LogUtil;
import mdm.cuf.person.adapter.vba.corp.server.inttest.stepdefs.AbstractMdmCufPersonAdapterVbaCorpStepDefs;
import mdm.cuf.person.bio.AddressBio;
import mdm.cuf.person.bio.EmailBio;
import mdm.cuf.person.bio.PersonBio;
import mdm.cuf.person.bio.TelephoneBio;
import mdm.cuf.person.bio.TelephoneType;

public class VbaCorpStepDefinitions extends AbstractMdmCufPersonAdapterVbaCorpStepDefs {
	Logger LOGGER = LoggerFactory.getLogger(VbaCorpStepDefinitions.class);

}