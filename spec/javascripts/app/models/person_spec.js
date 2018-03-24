
describe("app.models.Person", function() {
  beforeEach(function() {
    this.mutualContact = factory.person({relationship: "mutual"});
    this.sharingContact = factory.person({relationship: "sharing"});
    this.receivingContact = factory.person({relationship: "receiving"});
    this.blockedContact = factory.person({relationship: "sharing", block: {id: 1}});
  });

  describe("initialize", function() {
    it("sets contact object with person reference", function() {
      var contact = {id: factory.id.next()};
      var person = factory.person({contact: contact});
      expect(person.contact.get("id")).toEqual(contact.id);
      expect(person.contact.person).toEqual(person);
    });
  });

  context("#isSharing", function() {
    it("indicates if the person is sharing", function() {
      expect(this.mutualContact.isSharing()).toBeTruthy();
      expect(this.sharingContact.isSharing()).toBeTruthy();
      expect(this.blockedContact.isSharing()).toBeTruthy();

      expect(this.receivingContact.isSharing()).toBeFalsy();
    });
  });

  context("#isReceiving", function() {
    it("indicates if the person is receiving", function() {
      expect(this.mutualContact.isReceiving()).toBeTruthy();
      expect(this.receivingContact.isReceiving()).toBeTruthy();

      expect(this.sharingContact.isReceiving()).toBeFalsy();
      expect(this.blockedContact.isReceiving()).toBeFalsy();
    });
  });

  context("#isMutual", function() {
    it("indicates if we share mutually with the person", function() {
      expect(this.mutualContact.isMutual()).toBeTruthy();

      expect(this.receivingContact.isMutual()).toBeFalsy();
      expect(this.sharingContact.isMutual()).toBeFalsy();
      expect(this.blockedContact.isMutual()).toBeFalsy();
    });
  });

  context("#isBlocked", function() {
    it("indicates whether we blocked the person", function() {
      expect(this.blockedContact.isBlocked()).toBeTruthy();

      expect(this.mutualContact.isBlocked()).toBeFalsy();
      expect(this.receivingContact.isBlocked()).toBeFalsy();
      expect(this.sharingContact.isBlocked()).toBeFalsy();
    });
  });

  context("#block", function() {
    it("POSTs a block to the server", function() {
      this.sharingContact.block();
      var request = jasmine.Ajax.requests.mostRecent();

      expect(request.method).toEqual("POST");
      expect($.parseJSON(request.params).block.person_id).toEqual(this.sharingContact.id);
    });
  });

  context("#unblock", function() {
    it("DELETEs a block from the server", function(){
      this.blockedContact.unblock();
      var request = jasmine.Ajax.requests.mostRecent();

      expect(request.method).toEqual("DELETE");
      expect(request.url).toEqual(Routes.block(this.blockedContact.get("block").id));
    });
  });
});
