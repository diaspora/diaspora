describe("app.views.ContactStream", function() {
  beforeEach(function() {
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});
    spec.loadFixture("aspects_manage");
    this.contacts = new app.collections.Contacts();
    this.contactsData = $.parseJSON(spec.readFixture("contacts_json"));
    app.aspect = new app.models.Aspect(this.contactsData[0].aspect_memberships[0].aspect);
    this.view = new app.views.ContactStream({
      collection : this.contacts,
      el: $(".stream.contacts #contact_stream"),
      urlParams: "set=all"
    });
  });

  describe("initialize", function() {
    it("binds an infinite scroll listener", function() {
      spyOn($.fn, "scroll");
      new app.views.ContactStream({collection: this.contacts});
      expect($.fn.scroll).toHaveBeenCalled();
    });

    it("binds 'fetchContacts'", function() {
      spyOn(app.views.ContactStream.prototype, "fetchContacts");
      this.view = new app.views.ContactStream({collection: this.contacts});
      this.view.trigger("fetchContacts");
      expect(app.views.ContactStream.prototype.fetchContacts).toHaveBeenCalled();
    });

    it("sets the current page for pagination to 1", function() {
      expect(this.view.page).toBe(1);
    });

    it("sets urlParams to the given value", function() {
      expect(this.view.urlParams).toBe("set=all");
    });
  });

  describe("render", function() {
    it("calls fetchContacts", function() {
      spyOn(this.view, "fetchContacts");
      this.view.render();
      expect(this.view.fetchContacts).toHaveBeenCalled();
    });
  });

  describe("fetchContacts", function() {
    it("adds the loading class", function() {
      expect(this.view.$el).not.toHaveClass("loading");
      this.view.fetchContacts();
      expect(this.view.$el).toHaveClass("loading");
    });

    it("displays the loading spinner", function() {
      expect($("#paginate .loader")).toHaveClass("hidden");
      this.view.fetchContacts();
      expect($("#paginate .loader")).not.toHaveClass("hidden");
    });

    it("calls $.ajax with the URL given by _fetchUrl", function() {
      spyOn(this.view, "_fetchUrl").and.returnValue("/myAwesomeFetchUrl?foo=bar");
      this.view.fetchContacts();
      expect(jasmine.Ajax.requests.mostRecent().url).toBe("/myAwesomeFetchUrl?foo=bar");
    });

    it("calls onEmptyResponse on an empty response", function() {
      spyOn(this.view, "onEmptyResponse");
      this.view.fetchContacts();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, responseText: JSON.stringify([])});
      expect(this.view.onEmptyResponse).toHaveBeenCalled();
    });

    it("calls appendContactViews on a non-empty response", function() {
      spyOn(this.view, "appendContactViews");
      this.view.fetchContacts();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, responseText: JSON.stringify(this.contactsData)});
      expect(this.view.appendContactViews).toHaveBeenCalledWith(this.contactsData);
    });

    it("increases the current page on a non-empty response", function() {
      this.view.page = 42;
      this.view.fetchContacts();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, responseText: JSON.stringify(this.contactsData)});
      expect(this.view.page).toBe(43);
    });
  });

  describe("_fetchUrl", function() {
    it("returns the correct URL to fetch contacts", function() {
      this.view.page = 15;
      this.view.urlParams = undefined;
      expect(this.view._fetchUrl()).toBe("/contacts.json?page=15");
    });

    it("appends urlParams if those are set", function() {
      this.view.page = 23;
      expect(this.view._fetchUrl()).toBe("/contacts.json?page=23&set=all");
    });
  });

  describe("onEmptyResponse", function() {
    context("with an empty collection", function() {
      it("adds a 'no contacts' div", function() {
        this.view.onEmptyResponse();
        expect(this.view.$("#no_contacts").text().trim()).toBe(Diaspora.I18n.t("contacts.search_no_results"));
      });

      it("hides the loading spinner", function() {
        this.view.$el.addClass("loading");
        $("#paginate .loader").removeClass("hidden");
        this.view.onEmptyResponse();
        expect(this.view.$el).not.toHaveClass("loading");
        expect($("#paginate .loader")).toHaveClass("hidden");
      });

      it("unbinds 'fetchContacts'", function() {
        spyOn(this.view, "off");
        this.view.onEmptyResponse();
        expect(this.view.off).toHaveBeenCalledWith("fetchContacts");
      });
    });

    context("with a non-empty collection", function() {
      beforeEach(function() {
        this.view.collection.add(factory.contact());
      });

      it("adds no 'no contacts' div", function() {
        this.view.onEmptyResponse();
        expect(this.view.$("#no_contacts").length).toBe(0);
      });

      it("hides the loading spinner", function() {
        this.view.$el.addClass("loading");
        $("#paginate .loader").removeClass("hidden");
        this.view.onEmptyResponse();
        expect(this.view.$el).not.toHaveClass("loading");
        expect($("#paginate .loader")).toHaveClass("hidden");
      });

      it("unbinds 'fetchContacts'", function() {
        spyOn(this.view, "off");
        this.view.onEmptyResponse();
        expect(this.view.off).toHaveBeenCalledWith("fetchContacts");
      });
    });
  });

  describe("appendContactViews", function() {
    it("hides the loading spinner", function() {
      this.view.$el.addClass("loading");
      $("#paginate .loader").removeClass("hidden");
      this.view.appendContactViews(this.contactsData);
      expect(this.view.$el).not.toHaveClass("loading");
      expect($("#paginate .loader")).toHaveClass("hidden");
    });

    it("adds all contacts to an empty collection", function() {
      expect(this.view.collection.length).toBe(0);
      this.view.appendContactViews(this.contactsData);
      expect(this.view.collection.length).toBe(this.contactsData.length);
      expect(this.view.collection.pluck("id")).toEqual(_.pluck(this.contactsData, "id"));
    });

    it("appends contacts to an existing collection", function() {
      this.view.collection.add(this.contactsData[0]);
      expect(this.view.collection.length).toBe(1);
      this.view.appendContactViews(_.rest(this.contactsData));
      expect(this.view.collection.length).toBe(this.contactsData.length);
      expect(this.view.collection.pluck("id")).toEqual(_.pluck(this.contactsData, "id"));
    });

    it("renders all added contacts", function() {
      expect(this.view.$(".stream-element.contact").length).toBe(0);
      this.view.appendContactViews(this.contactsData);
      expect(this.view.$(".stream-element.contact").length).toBe(this.contactsData.length);
    });

    it("appends contacts to an existing contact list", function() {
      this.view.appendContactViews([this.contactsData[0]]);
      expect(this.view.$(".stream-element.contact").length).toBe(1);
      this.view.appendContactViews(_.rest(this.contactsData));
      expect(this.view.$(".stream-element.contact").length).toBe(this.contactsData.length);
    });
  });

  describe("infScroll", function() {
    beforeEach(function() {
      this.view.off("fetchContacts");
      this.fn = jasmine.createSpy();
      this.view.on("fetchContacts", this.fn);
      spyOn($.fn, "height").and.returnValue(0);
      spyOn($.fn, "scrollTop").and.returnValue(100);
    });

    it("triggers fetchContacts when the user is at the bottom of the page", function() {
      this.view.infScroll();
      expect(this.fn).toHaveBeenCalled();
    });
  });
});
