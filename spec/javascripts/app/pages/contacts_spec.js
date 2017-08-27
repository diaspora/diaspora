describe("app.pages.Contacts", function(){
  beforeEach(function() {
    spec.loadFixture("aspects_manage");
    var contactsData = spec.readFixture("aspects_manage_contacts_json");
    app.contacts = new app.collections.Contacts(JSON.parse(contactsData));
    this.view = new app.pages.Contacts({
      stream: {
        render: function(){},
        collection: app.contacts
      }
    });
  });

  context('toggle chat privilege', function() {
    beforeEach(function() {
      this.chatToggle = $("#chat_privilege_toggle");
      this.chatIcon = $("#chat_privilege_toggle i");
    });

    it('updates the title for the tooltip', function() {
      expect(this.chatIcon.attr("data-original-title")).toBe(
        Diaspora.I18n.t("contacts.aspect_chat_is_not_enabled")
      );
      this.chatToggle.trigger("click");
      expect(this.chatIcon.attr("data-original-title")).toBe(
        Diaspora.I18n.t("contacts.aspect_chat_is_enabled")
      );
    });

    it("toggles the chat icon", function() {
      expect(this.chatIcon.hasClass("enabled")).toBeFalsy();
      this.chatToggle.trigger("click");
      expect(this.chatIcon.hasClass("enabled")).toBeTruthy();
    });
  });

  context('toggle contacts visibility', function() {
    beforeEach(function() {
      this.visibilityToggle = $("#contacts_visibility_toggle");
      this.lockIcon = $("#contacts_visibility_toggle i");
    });

    it("updates the title for the tooltip", function() {
      expect(this.lockIcon.attr("data-original-title")).toBe(
        Diaspora.I18n.t("contacts.aspect_list_is_visible")
      );

      this.visibilityToggle.trigger("click");

      expect(this.lockIcon.attr("data-original-title")).toBe(
        Diaspora.I18n.t("contacts.aspect_list_is_not_visible")
      );
    });

    it("toggles the lock icon", function() {
      expect(this.lockIcon.hasClass("entypo-lock-open")).toBeTruthy();
      expect(this.lockIcon.hasClass("entypo-lock")).toBeFalsy();

      this.visibilityToggle.trigger("click");

      expect(this.lockIcon.hasClass("entypo-lock")).toBeTruthy();
      expect(this.lockIcon.hasClass("entypo-lock-open")).toBeFalsy();
    });
  });

  context('show aspect name form', function() {
    beforeEach(function() {
      this.button = $('#change_aspect_name');
    });

    it('shows the form', function() {
      expect($('#aspect_name_form').css('display')).toBe('none');
      this.button.trigger('click');
      expect($('#aspect_name_form').css('display')).not.toBe('none');
    });

    it('hides the aspect name', function() {
      expect($('.header > h3').css('display')).not.toBe('none');
      this.button.trigger('click');
      expect($('.header > h3').css('display')).toBe('none');
    });

    it("sets the current aspect name as the default value in the form", function() {
      $(".header > h3 #aspect_name").text("My awesome unicorn aspect");
      expect($("#aspect_name_form input[name='aspect[name]']").val()).not.toBe("My awesome unicorn aspect");
      this.button.trigger("click");
      expect($("#aspect_name_form input[name='aspect[name]']").val()).toBe("My awesome unicorn aspect");
    });
  });

  describe("updateBadgeCount", function() {
    it("increases the badge count of an aspect", function() {
      var aspect = $("#aspect_nav .aspect").eq(0);
      $(".badge", aspect).text("15");
      this.view.updateBadgeCount("[data-aspect-id='" + aspect.data("aspect-id") + "']", 27);
      expect($(".badge", aspect).text()).toBe("42");
    });

    it("decreases the badge count of an aspect", function() {
      var aspect = $("#aspect_nav .aspect").eq(1);
      $(".badge", aspect).text("42");
      this.view.updateBadgeCount("[data-aspect-id='" + aspect.data("aspect-id") + "']", -15);
      expect($(".badge", aspect).text()).toBe("27");
    });

    it("increases the badge count of 'my aspects'", function() {
      $("#aspect_nav .all_aspects .badge").text("15");
      this.view.updateBadgeCount(".all_aspects", 27);
      expect($("#aspect_nav .all_aspects .badge").text()).toBe("42");
    });

    it("decreases the badge count of 'my aspects'", function() {
      $("#aspect_nav .all_aspects .badge").text("42");
      this.view.updateBadgeCount(".all_aspects", -15);
      expect($("#aspect_nav .all_aspects .badge").text()).toBe("27");
    });
  });

  describe("addAspectMembership", function() {
    context("when the user starts sharing", function() {
      beforeEach(function() {
        this.contact = app.contacts.first();
        this.data = {
          membership: {
            aspectId: $("#aspect_nav .aspect").eq(1).data("aspect-id"),
            personId: this.contact.person.id
          },
          startSharing: true
        };
        spyOn(this.view, "updateBadgeCount").and.callThrough();
      });

      it("is called on aspect_membership:create", function() {
        spyOn(app.pages.Contacts.prototype, "addAspectMembership");
        this.view = new app.pages.Contacts({stream: {render: function(){}, collection: app.contacts}});
        app.events.trigger("aspect_membership:create", this.data);
        expect(app.pages.Contacts.prototype.addAspectMembership).toHaveBeenCalledWith(this.data);
      });

      it("calls updateContactCount for 'all aspects'", function() {
        this.view.addAspectMembership(this.data);
        expect(this.view.updateBadgeCount).toHaveBeenCalledWith(".all_aspects", 1);
      });

      it("calls updateBadgeCount for the aspect", function() {
        this.view.addAspectMembership(this.data);
        expect(this.view.updateBadgeCount).toHaveBeenCalledWith(
          "[data-aspect-id='" + this.data.membership.aspectId + "']", 1
        );
      });

      it("calls updateContactCount for 'all contacts' if there was no relationship before", function() {
        this.contact.person.set({relationship: "not_sharing"});
        this.view.addAspectMembership(this.data);
        expect(this.view.updateBadgeCount).toHaveBeenCalledWith(".all_contacts", 1);
        expect(this.contact.person.get("relationship")).toBe("receiving");
      });

      it("calls updateContactCount for 'only sharing' if the relationship was 'sharing'", function() {
        this.contact.person.set({relationship: "sharing"});
        this.view.addAspectMembership(this.data);
        expect(this.view.updateBadgeCount).toHaveBeenCalledWith(".only_sharing", -1);
        expect(this.contact.person.get("relationship")).toBe("mutual");
      });
    });

    context("when the user doesn't start sharing", function() {
      beforeEach(function() {
        this.data = {
          membership: {
            aspectId: $("#aspect_nav .aspect").eq(1).data("aspect-id"),
            personId: app.contacts.first().person.id
          },
          startSharing: false
        };
        spyOn(this.view, "updateBadgeCount").and.callThrough();
      });

      it("is called on aspect_membership:create", function() {
        spyOn(app.pages.Contacts.prototype, "addAspectMembership");
        this.view = new app.pages.Contacts({stream: {render: function(){}, collection: app.contacts}});
        app.events.trigger("aspect_membership:create", this.data);
        expect(app.pages.Contacts.prototype.addAspectMembership).toHaveBeenCalledWith(this.data);
      });

      it("doesn't call updateBadgeCount for 'all aspects'", function() {
        this.view.addAspectMembership(this.data);
        expect(this.view.updateBadgeCount).not.toHaveBeenCalledWith(".all_aspects", 1);
      });

      it("calls updateBadgeCount for the aspect", function() {
        this.view.addAspectMembership(this.data);
        expect(this.view.updateBadgeCount).toHaveBeenCalledWith(
          "[data-aspect-id='" + this.data.membership.aspectId + "']", 1
        );
      });
    });
  });

  describe("removeAspectMembership", function() {
    context("when the user stops sharing", function() {
      beforeEach(function() {
        this.contact = app.contacts.first();
        this.data = {
          membership: {
            aspectId: $("#aspect_nav .aspect").eq(0).data("aspect-id"),
            personId: this.contact.person.id
          },
          stopSharing: true
        };
        spyOn(this.view, "updateBadgeCount").and.callThrough();
      });

      it("is called on aspect_membership:destroy", function() {
        spyOn(app.pages.Contacts.prototype, "removeAspectMembership");
        this.view = new app.pages.Contacts({stream: {render: function(){}, collection: app.contacts}});
        app.events.trigger("aspect_membership:destroy", this.data);
        expect(app.pages.Contacts.prototype.removeAspectMembership).toHaveBeenCalledWith(this.data);
      });

      it("calls updateContactCount for 'all aspects'", function() {
        this.view.removeAspectMembership(this.data);
        expect(this.view.updateBadgeCount).toHaveBeenCalledWith(".all_aspects", -1);
      });

      it("calls updateBadgeCount for the aspect", function() {
        this.view.removeAspectMembership(this.data);
        expect(this.view.updateBadgeCount).toHaveBeenCalledWith(
          "[data-aspect-id='" + this.data.membership.aspectId + "']", -1
        );
      });

      it("calls updateContactCount for 'all contacts' if the relationship was 'receiving'", function() {
        this.contact.person.set({relationship: "receiving"});
        this.view.removeAspectMembership(this.data);
        expect(this.view.updateBadgeCount).toHaveBeenCalledWith(".all_contacts", -1);
        expect(this.contact.person.get("relationship")).toBe("not_sharing");
      });

      it("calls updateContactCount for 'only sharing' if the relationship was 'mutual'", function() {
        this.contact.person.set({relationship: "mutual"});
        this.view.removeAspectMembership(this.data);
        expect(this.view.updateBadgeCount).toHaveBeenCalledWith(".only_sharing", 1);
        expect(this.contact.person.get("relationship")).toBe("sharing");
      });
    });

    context("when the user doesn't stop sharing", function() {
      beforeEach(function() {
        this.data = {
          membership: {
            aspectId: $("#aspect_nav .aspect").eq(0).data("aspect-id"),
            personId: app.contacts.first().person.id
          },
          stopSharing: false
        };
        spyOn(this.view, "updateBadgeCount").and.callThrough();
      });

      it("is called on aspect_membership:destroy", function() {
        spyOn(app.pages.Contacts.prototype, "removeAspectMembership");
        this.view = new app.pages.Contacts({stream: {render: function(){}, collection: app.contacts}});
        app.events.trigger("aspect_membership:destroy", this.data);
        expect(app.pages.Contacts.prototype.removeAspectMembership).toHaveBeenCalledWith(this.data);
      });

      it("doesn't call updateBadgeCount for 'all aspects'", function() {
        this.view.removeAspectMembership(this.data);
        expect(this.view.updateBadgeCount).not.toHaveBeenCalledWith(".all_aspects", -1);
      });

      it("calls updateBadgeCount for the aspect", function() {
        this.view.removeAspectMembership(this.data);
        expect(this.view.updateBadgeCount).toHaveBeenCalledWith(
          "[data-aspect-id='" + this.data.membership.aspectId + "']", -1
        );
      });
    });
  });

  describe("showMessageModal", function() {
    beforeEach(function() {
      spec.content().append("<div id='conversationModal'/>");
    });

    it("calls app.helpers.showModal", function() {
      spyOn(app.helpers, "showModal");
      this.view.showMessageModal();
      expect(app.helpers.showModal).toHaveBeenCalled();
    });

    it("initializes app.views.ConversationsForm with correct parameters when modal is loaded", function() {
      spyOn(app.views.ConversationsForm.prototype, "initialize");
      app.aspect = new app.models.Aspect(app.contacts.first().get("aspect_memberships")[0].aspect);
      this.view.showMessageModal();
      $("#conversationModal").trigger("modal:loaded");
      expect(app.views.ConversationsForm.prototype.initialize).toHaveBeenCalled();

      var prefill = app.views.ConversationsForm.prototype.initialize.calls.mostRecent().args[0].prefill;
      var contacts = app.contacts.filter(function(contact) { return contact.inAspect(app.aspect.get("id")); });
      expect(_.pluck(prefill, "id")).toEqual(contacts.map(function(contact) { return contact.person.id; }));
    });
  });
});
