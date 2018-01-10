package org.mdm.cuf.person.adapter.vba.corp.bgs.endpoints;

import gov.va.vba.vet360.services.address.MessageException;
import gov.va.vba.vet360.services.address.ObjectFactory;
import gov.va.vba.vet360.services.address.UpdateMailingAddressResponse;
import gov.va.vba.vet360.services.address.Vet360MailingAddressActionsPort;

public class Vet360MailingAddressActionsImpl implements Vet360MailingAddressActionsPort {

    @Override
    public String updateMailingAddress(Long ptcpntAddrsId) throws MessageException {
        ObjectFactory factory = new ObjectFactory();
        UpdateMailingAddressResponse response = factory.createUpdateMailingAddressResponse();
        return response.getReturnCode();
    }
}
