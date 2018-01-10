
package mdm.cuf.person.adapter.vba.corp.server.runners;

import org.junit.runner.RunWith;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;
import mdm.cuf.core.server.inttest.AbstractMdmCufCoreIntTestRunner;

@RunWith(Cucumber.class)
@CucumberOptions(plugin = { "com.cucumber.listener.ExtentCucumberFormatter:", "html:target/cucumber", "json:target/report.json" },

		features = {"./src/main/resources/static/features/adapter/" },
			
		glue = "mdm/cuf/person/adapter/vba/corp/server/step_definitions",
			
        tags = {"@CORPMember", "~@Manual"}
)

public class MdmCufPersonAdapterVbaCorp_Runner extends AbstractMdmCufCoreIntTestRunner {

}
