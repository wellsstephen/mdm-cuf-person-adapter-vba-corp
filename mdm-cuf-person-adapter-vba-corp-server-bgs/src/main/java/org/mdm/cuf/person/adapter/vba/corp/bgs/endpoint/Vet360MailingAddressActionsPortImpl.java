package org.mdm.cuf.person.adapter.vba.corp.bgs.endpoint;

import javax.jws.WebService;

import gov.va.vba.vet360.services.address.MessageException;
import gov.va.vba.vet360.services.address.ObjectFactory;
import gov.va.vba.vet360.services.address.UpdateMailingAddressResponse;
import gov.va.vba.vet360.services.address.Vet360MailingAddressActionsPort;

@WebService(name = "Vet360MailingAddressActionsPort", targetNamespace = "http://address.services.vet360.vba.va.gov/",
            portName= "Vet360MailingAddressActionsPort", serviceName= "Vet360MailingAddressActions",
            wsdlLocation = "/wsdl/Vet360MailingAddressActions.wsdl")

public class Vet360MailingAddressActionsPortImpl implements Vet360MailingAddressActionsPort {

    @Override
    public String updateMailingAddress(Long ptcpntAddrsId) throws MessageException {
        ObjectFactory factory = new ObjectFactory();
        UpdateMailingAddressResponse createUpdateMailingAddressResponse = factory.createUpdateMailingAddressResponse();
        createUpdateMailingAddressResponse.setReturnCode("RECEIVED");
        return createUpdateMailingAddressResponse.getReturnCode();
    }

}
