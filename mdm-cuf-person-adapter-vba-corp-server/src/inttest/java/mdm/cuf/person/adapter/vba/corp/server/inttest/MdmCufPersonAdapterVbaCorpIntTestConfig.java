package mdm.cuf.person.adapter.vba.corp.server.inttest;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

import mdm.cuf.core.server.inttest.AbstractMdmCufCoreIntTestConfig;

@Configuration
@ComponentScan(basePackages = { "mdm.cuf.person.adapter.vba.corp.server.inttest" })
public class MdmCufPersonAdapterVbaCorpIntTestConfig extends AbstractMdmCufCoreIntTestConfig {

    @Bean
    public MdmCufPersonAdapterVbaCorpIntTestProperties mdmCufPersonAdapterVbaCorpIntTestProperties(){
        return new MdmCufPersonAdapterVbaCorpIntTestProperties();
    }
}
