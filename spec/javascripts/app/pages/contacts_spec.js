describe("app.pages.Contacts", function(){
  beforeEach(function() {
    spec.loadFixture("aspects_manage");
    this.view = new app.pages.Contacts({
      stream: {
        render: function(){}
      }
    });
    Diaspora.I18n.load({
      contacts: {
        aspect_list_is_visible: "Contacts in this aspect are able to see each other.",
        aspect_list_is_not_visible: "Contacts in this aspect are not able to see each other.",
        aspect_chat_is_enabled: "Contacts in this aspect are able to chat with you.",
        aspect_chat_is_not_enabled: "Contacts in this aspect are not able to chat with you.",
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
  });

  context('search contact list', function() {
    beforeEach(function() {
      this.searchinput = $('#contact_list_search');
    });

    it('calls stream.search', function() {
      this.view.stream.search = jasmine.createSpy();
      this.searchinput.val("Username");
      this.searchinput.trigger('keyup');
      expect(this.view.stream.search).toHaveBeenCalledWith("Username");
    });
  });
});
