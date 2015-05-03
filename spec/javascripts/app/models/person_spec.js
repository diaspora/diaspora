
describe("app.models.Person", function() {
  beforeEach(function() {
    this.mutual_contact = factory.person({relationship: 'mutual'});
    this.sharing_contact = factory.person({relationship :'sharing'});
    this.receiving_contact = factory.person({relationship: 'receiving'});
    this.blocked_contact = factory.person({relationship: 'blocked', block: {id: 1}});
  });

  context("#isSharing", function() {
    it("indicates if the person is sharing", function() {
      expect(this.mutual_contact.isSharing()).toBeTruthy();
      expect(this.sharing_contact.isSharing()).toBeTruthy();

      expect(this.receiving_contact.isSharing()).toBeFalsy();
      expect(this.blocked_contact.isSharing()).toBeFalsy();
    });
  });

  context("#isReceiving", function() {
    it("indicates if the person is receiving", function() {
      expect(this.mutual_contact.isReceiving()).toBeTruthy();
      expect(this.receiving_contact.isReceiving()).toBeTruthy();

      expect(this.sharing_contact.isReceiving()).toBeFalsy();
      expect(this.blocked_contact.isReceiving()).toBeFalsy();
    });
  });

  context("#isMutual", function() {
    it("indicates if we share mutually with the person", function() {
      expect(this.mutual_contact.isMutual()).toBeTruthy();

      expect(this.receiving_contact.isMutual()).toBeFalsy();
      expect(this.sharing_contact.isMutual()).toBeFalsy();
      expect(this.blocked_contact.isMutual()).toBeFalsy();
    });
  });

  context("#isBlocked", function() {
    it("indicates whether we blocked the person", function() {
      expect(this.blocked_contact.isBlocked()).toBeTruthy();

      expect(this.mutual_contact.isBlocked()).toBeFalsy();
      expect(this.receiving_contact.isBlocked()).toBeFalsy();
      expect(this.sharing_contact.isBlocked()).toBeFalsy();
    });
  });

  context("#block", function() {
    it("POSTs a block to the server", function() {
      this.sharing_contact.block();
      var request = jasmine.Ajax.requests.mostRecent();

      expect(request.method).toEqual("POST");
      expect($.parseJSON(request.params).block.person_id).toEqual(this.sharing_contact.id);
    });
  });

  context("#unblock", function() {
    it("DELETEs a block from the server", function(){
      this.blocked_contact.unblock();
      var request = jasmine.Ajax.requests.mostRecent();

      expect(request.method).toEqual("DELETE");
      expect(request.url).toEqual(Routes.block_path(this.blocked_contact.get('block').id));
    });
  });
});
