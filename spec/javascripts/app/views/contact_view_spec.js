describe("app.views.Contact", function(){
  beforeEach(function() {
    this.aspect1 = factory.aspect({id: 1});
    this.aspect2 = factory.aspect({id: 2});

    this.model = new app.models.Contact({
      person_id: 42,
      person: { id: 42, name: "alice" },
      aspect_memberships: [{id: 23, aspect: this.aspect1}]
    });
    this.view = new app.views.Contact({ model: this.model });
  });

  context("#presenter", function() {
    it("contains necessary elements", function() {
      app.aspect = this.aspect1;
      expect(this.view.presenter()).toEqual(jasmine.objectContaining({
        person_id: 42,
        person: jasmine.objectContaining({id: 42, name: "alice"}),
        in_aspect: 'in_aspect'
      }));
    });
  });

  context("add contact to aspect", function() {
    beforeEach(function() {
      app.aspect = this.aspect2;
      this.view.render();
      this.view.$el.append($("<div id='flash-container'/>"));
      app.flashMessages = new app.views.FlashMessages({ el: this.view.$("#flash-container") });
      this.button = this.view.$el.find(".contact_add-to-aspect");
      this.contact = this.view.$el.find(".stream-element.contact");
      this.aspectMembership = {id: 42, aspect: app.aspect.toJSON()};
      this.response = JSON.stringify(this.aspectMembership);
    });

    it("sends a correct ajax request", function() {
      this.button.trigger("click");
      var obj = $.parseJSON(jasmine.Ajax.requests.mostRecent().params);
      expect(obj.person_id).toBe(this.model.get('person_id'));
      expect(obj.aspect_id).toBe(app.aspect.get('id'));
    });

    it("adds a aspect_membership to the contact", function() {
      expect(this.model.aspectMemberships.length).toBe(1);
      $(".contact_add-to-aspect",this.contact).trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200, // success
        responseText: this.response
      });
      expect(this.model.aspectMemberships.length).toBe(2);
    });

    it("triggers aspect_membership:create", function() {
      spyOn(app.events, "trigger");
      $(".contact_add-to-aspect", this.contact).trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200, // success
        responseText: this.response
      });
      expect(app.events.trigger).toHaveBeenCalledWith("aspect_membership:create", {
        membership: {aspectId: app.aspect.get("id"), personId: this.model.get("person_id")},
        startSharing: false
      });
    });

    it("calls render", function() {
      spyOn(this.view, "render");
      $(".contact_add-to-aspect",this.contact).trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200, // success
        responseText: this.response
      });
      expect(this.view.render).toHaveBeenCalled();
    });


    it("displays a flash message on errors", function(){
      $(".contact_add-to-aspect",this.contact).trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 400 // fail
      });
      expect(this.view.$(".flash-message")).toBeErrorFlashMessage(
        Diaspora.I18n.t( "contacts.error_add", {name: this.model.get("person").name} )
      );
    });
  });

  context("remove contact from aspect", function() {
    beforeEach(function() {
      app.aspect = this.aspect1;
      this.view.render();
      this.view.$el.append($("<div id='flash-container'/>"));
      app.flashMessages = new app.views.FlashMessages({ el: this.view.$("#flash-container") });
      this.button = this.view.$el.find(".contact_remove-from-aspect");
      this.contact = this.view.$el.find(".stream-element.contact");
      this.aspectMembership = this.model.aspectMemberships.first().toJSON();
      this.response = JSON.stringify(this.aspectMembership);
    });

    it("sends a correct ajax request", function() {
      $(".contact_remove-from-aspect",this.contact).trigger("click");
      expect(jasmine.Ajax.requests.mostRecent().url).toBe(
        "/aspect_memberships/"+this.aspectMembership.id
      );
    });

    it("removes the aspect_membership from the contact", function() {
      expect(this.model.aspectMemberships.length).toBe(1);
      $(".contact_remove-from-aspect",this.contact).trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200, // success
        responseText: this.response
      });
      expect(this.model.aspectMemberships.length).toBe(0);
    });

    it("triggers aspect_membership:destroy", function() {
      spyOn(app.events, "trigger");
      $(".contact_remove-from-aspect", this.contact).trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200, // success
        responseText: this.response
      });
      expect(app.events.trigger).toHaveBeenCalledWith("aspect_membership:destroy", {
        membership: {aspectId: app.aspect.get("id"), personId: this.model.get("person_id")},
        stopSharing: true
      });
    });

    it("calls render", function() {
      spyOn(this.view, "render");
      $(".contact_remove-from-aspect",this.contact).trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200, // success
        responseText: this.response,
      });
      expect(this.view.render).toHaveBeenCalled();
    });

    it("displays a flash message on errors", function(){
      $(".contact_remove-from-aspect",this.contact).trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 400 // fail
      });
      expect(this.view.$(".flash-message")).toBeErrorFlashMessage(
        Diaspora.I18n.t( "contacts.error_remove", {name: this.model.get("person").name})
      );
    });
  });

});
