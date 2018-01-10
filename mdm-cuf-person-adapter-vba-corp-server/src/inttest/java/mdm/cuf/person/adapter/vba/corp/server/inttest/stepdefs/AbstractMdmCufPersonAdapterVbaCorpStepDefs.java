package mdm.cuf.person.adapter.vba.corp.server.inttest.stepdefs;

import static com.jayway.restassured.RestAssured.given;

import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.jayway.restassured.http.ContentType;
import com.jayway.restassured.response.Response;
import com.jayway.restassured.specification.RequestSpecification;

import mdm.cuf.core.api.CufResponse;
import mdm.cuf.core.api.CufStatusResponse;
import mdm.cuf.core.api.CufTxStatus;
//import mdm.cuf.core.bio.Bio;
import mdm.cuf.core.server.inttest.AbstractMdmCufCoreStepDefs;
import mdm.cuf.person.adapter.vba.corp.server.inttest.MdmCufPersonAdapterVbaCorpIntTestConfig;
import mdm.cuf.person.adapter.vba.corp.server.inttest.MdmCufPersonAdapterVbaCorpIntTestProperties;
import mdm.cuf.person.bio.PersonBio;
import mdm.cuf.person.bio.TelephoneBio;



@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = MdmCufPersonAdapterVbaCorpIntTestConfig.class)
public abstract class AbstractMdmCufPersonAdapterVbaCorpStepDefs extends AbstractMdmCufCoreStepDefs {

	/**
	 * Amount of sleep time to use between various steps where the queue could
	 * come into play
	 */
	protected static final int THREAD_SLEEP_MILLIS_TO_ALLOW_DEQ = 250; // even
	                                                                   // with
																		// embedded
																		// kakfa,
																		// still
																		// can
																		// take
																		// a
																		// moment
																		// to
																		// dequeue
	protected static final int THREAD_SLEEP_TRIES = 15;
	Logger LOGGER = LoggerFactory.getLogger(AbstractMdmCufPersonAdapterVbaCorpStepDefs.class);

	@Autowired
	private MdmCufPersonAdapterVbaCorpIntTestProperties inttestProps;

	protected MdmCufPersonAdapterVbaCorpIntTestProperties getInttestProps() {
		return inttestProps;
	}

}