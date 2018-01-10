package org.mdm.cuf.person.adapter.vba.corp.bgs.provider;

import javax.jws.WebService;

import gov.va.vba.vet360.services.address.MessageException;
import gov.va.vba.vet360.services.address.ObjectFactory;
import gov.va.vba.vet360.services.address.UpdateMailingAddressResponse;
import gov.va.vba.vet360.services.address.Vet360MailingAddressActionsPort;

@WebService(name = "gov.va.vba.vet360.services.address.Vet360MailingAddressActionsPort", targetNamespace = "http://address.services.vet360.vba.va.gov/",
            portName = "Vet360MailingAddressActionsPort", serviceName = "Vet360MailingAddressActions",
            wsdlLocation = "/wsdl/Vet360MailingAddressActions.wsdl")
public class AddressManagementSOAPProvider implements Vet360MailingAddressActionsPort  {

    @Override
    public String updateMailingAddress(Long ptcpntAddrsId) throws MessageException {
        /** I'm not sure if any of this is right */
        /**
        JaxWsProxyFactoryBean jaxWsProxyFactoryBean = new JaxWsProxyFactoryBean();
        jaxWsProxyFactoryBean.setServiceClass(Vet360MailingAddressActions.class);
        jaxWsProxyFactoryBean.setAddress("http://localhost:7001/Vet360MailingAddressActionsBean/Vet360MailingAddressActions");
        UpdateMailingAddressResponse create = (UpdateMailingAddressResponse)jaxWsProxyFactoryBean.create();
        return create.getReturnCode();
        */
        ObjectFactory factory = new ObjectFactory();
        UpdateMailingAddressResponse updateMailingAddressResponse = factory.createUpdateMailingAddressResponse();
        return updateMailingAddressResponse.getReturnCode();
    }

}
