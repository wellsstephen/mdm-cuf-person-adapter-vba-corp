package org.mdm.cuf.person.adapter.vba.corp.bgs;

import javax.xml.ws.Endpoint;

import org.apache.cxf.Bus;
import org.apache.cxf.jaxws.EndpointImpl;
import org.mdm.cuf.person.adapter.vba.corp.bgs.endpoint.Vet360MailingAddressActionsPortImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import mdm.cuf.core.server.ws.client.BaseMdmCufCoreServerWsClientConfig;

/**
 * Configuration class for cxf web service implementator
 *
 * @author imcewan
 */
@Configuration @EnableAutoConfiguration
public class SOAPServiceConfig extends BaseMdmCufCoreServerWsClientConfig {

    private static final Logger LOGGER = LoggerFactory.getLogger(SOAPServiceConfig.class);

	@Autowired
	private Bus bus;

	@Bean
	public Endpoint endpoint() {
		Endpoint endpoint = new EndpointImpl(bus, new Vet360MailingAddressActionsPortImpl());
        endpoint.publish("/Vet360MailingAddressActions");
        LOGGER.debug("Address Endpoint Set up");
		return endpoint;
	}

}
