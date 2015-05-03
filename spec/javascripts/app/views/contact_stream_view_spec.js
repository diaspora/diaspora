describe("app.views.ContactStream", function() {
  beforeEach(function() {
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});
    spec.loadFixture("aspects_manage");
    this.contacts = new app.collections.Contacts($.parseJSON(spec.readFixture("contacts_json")));
    app.aspect = new app.models.Aspect(this.contacts.first().get('aspect_memberships')[0].aspect);
    this.view = new app.views.ContactStream({
      collection : this.contacts,
      el: $('.stream.contacts #contact_stream')
    });

    this.view.perPage=1;

    //clean the page
    this.view.$el.html('');
  });

  describe("initialize", function() {
    it("binds an infinite scroll listener", function() {
      spyOn($.fn, "scroll");
      new app.views.ContactStream({collection : this.contacts});
      expect($.fn.scroll).toHaveBeenCalled();
    });
  });

  describe("search", function() {
    it("filters the contacts", function() {
      this.view.render();
      expect(this.view.$el.html()).toContain("alice");
      this.view.search("eve");
      expect(this.view.$el.html()).not.toContain("alice");
      expect(this.view.$el.html()).toContain("eve");
    });
  });

  describe("infScroll", function() {
    beforeEach(function() {
      this.view.off("renderContacts");
      this.fn = jasmine.createSpy();
      this.view.on("renderContacts", this.fn);
      spyOn($.fn, "height").and.returnValue(0);
      spyOn($.fn, "scrollTop").and.returnValue(100);
    });

    it("triggers renderContacts when the user is at the bottom of the page", function() {
      this.view.infScroll();
      expect(this.fn).toHaveBeenCalled();
    });
  });

  describe("render", function() {
    beforeEach(function() {
      spyOn(this.view, "renderContacts");
    });

    it("calls renderContacts", function() {
      this.view.render();
      expect(this.view.renderContacts).toHaveBeenCalled();
    });
  });

  describe("renderContacts", function() {
    beforeEach(function() {
      this.view.off("renderContacts");
      this.view.renderContacts();
    });

    it("renders perPage contacts", function() {
      expect(this.view.$el.find('.stream_element.contact').length).toBe(1);
    });

    it("renders more contacts when called a second time", function() {
      this.view.renderContacts();
      expect(this.view.$el.find('.stream_element.contact').length).toBe(2);
    });
  });
});
