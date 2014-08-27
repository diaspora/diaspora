describe("app.views.Contacts", function(){
  beforeEach(function() {
    spec.loadFixture("aspects_manage");
    this.view = new app.views.Contacts();
    Diaspora.I18n.load({
      contacts: {
        add_contact: "Add contact",
        aspect_list_is_visible: "Contacts in this aspect are able to see each other.",
        aspect_list_is_not_visible: "Contacts in this aspect are not able to see each other.",
        remove_contact: "Remove contact",
        error_add: "Couldn't add <%= name %> to the aspect :(",
        error_remove: "Couldn't remove <%= name %> from the aspect :("
      }
    });
  });

  context('toggle contacts visibility', function() {
    beforeEach(function() {
      this.visibility_toggle = $("#contacts_visibility_toggle");
      this.lock_icon = $("#contacts_visibility_toggle .entypo");
    });

    it('updates the title for the tooltip', function() {
      expect(this.lock_icon.attr('data-original-title')).toBe(
        Diaspora.I18n.t("contacts.aspect_list_is_visible")
      );

      this.visibility_toggle.trigger('click');

      expect(this.lock_icon.attr('data-original-title')).toBe(
        Diaspora.I18n.t("contacts.aspect_list_is_not_visible")
      );
    });

    it('toggles the lock icon', function() {
      expect(this.lock_icon.hasClass('lock-open')).toBeTruethy;
      expect(this.lock_icon.hasClass('lock')).toBeFalsy;

      this.visibility_toggle.trigger('click');

      expect(this.lock_icon.hasClass('lock')).toBeTruethy;
      expect(this.lock_icon.hasClass('lock-open')).toBeFalsy;
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

  context('add contact to aspect', function() {
    beforeEach(function() {
      this.contact = $('#people_stream .stream_element').last();
      this.button = this.contact.find('.contact_add-to-aspect');
      this.person_id = this.button.attr('data-person_id');
      this.aspect_id = this.button.attr('data-aspect_id');
    });

    it('sends a correct ajax request', function() {
      jasmine.Ajax.install();
      $('.contact_add-to-aspect',this.contact).trigger('click');
      var obj = $.parseJSON(jasmine.Ajax.requests.mostRecent().params);
      expect(obj.person_id).toBe(this.person_id);
      expect(obj.aspect_id).toBe(this.aspect_id);
    });

    it('adds a membership id to the contact', function() {
      jasmine.Ajax.install();
      $('.contact_add-to-aspect',this.contact).trigger('click');
      jasmine.Ajax.requests.mostRecent().response({
        status: 200, // success
        responseText: '{ "id": 42 }'
      });
      expect(this.button.attr('data-membership_id')).toBe('42');
    });

    it('displays a flash message on errors', function(){
      jasmine.Ajax.install();
      $('.contact_add-to-aspect',this.contact).trigger('click');
      jasmine.Ajax.requests.mostRecent().response({
        status: 400, // fail
      });
      expect($('[id^="flash"]')).toBeErrorFlashMessage(
        Diaspora.I18n.t(
          'contacts.error_add',
          {name: this.contact.find('.name').text()}
        )
      );
    });

    it('changes the appearance of the contact', function() {
      expect(this.button.hasClass('contact_add-to-aspect')).toBeTruethy;
      expect(this.button.hasClass('circled-cross')).toBeTruethy;
      expect(this.contact.hasClass('in_aspect')).toBeTruethy;
      expect(this.button.hasClass('contact_remove-from-aspect')).toBeFalsy;
      expect(this.button.hasClass('circled-plus')).toBeFalsy;
      expect(this.button.attr('data-original-title')).toBe(
        Diaspora.I18n.t('contacts.add_contact')
      );
      jasmine.Ajax.install();
      $('.contact_add-to-aspect',this.contact).trigger('click');
      jasmine.Ajax.requests.mostRecent().response({
        status: 200, // success
        responseText: '{ "id": 42 }'
      });
      expect(this.button.hasClass('contact_add-to-aspect')).toBeFalsy;
      expect(this.button.hasClass('circled-cross')).toBeFalsy;
      expect(this.contact.hasClass('in_aspect')).toBeFalsy;
      expect(this.button.hasClass('contact_remove-from-aspect')).toBeTruethy;
      expect(this.button.hasClass('circled-plus')).toBeTruethy;
      expect(this.button.attr('data-original-title')).toBe(
        Diaspora.I18n.t('contacts.remove_contact')
      );
    });
  });

  context('remove contact from aspect', function() {
    beforeEach(function() {
      this.contact = $('#people_stream .stream_element').first();
      this.button = this.contact.find('.contact_remove-from-aspect');
      this.person_id = this.button.attr('data-person_id');
      this.aspect_id = this.button.attr('data-aspect_id');
      this.membership_id = this.button.attr('data-membership_id');

    });

    it('sends a correct ajax request', function() {
      jasmine.Ajax.install();
      $('.contact_remove-from-aspect',this.contact).trigger('click');
      expect(jasmine.Ajax.requests.mostRecent().url).toBe(
        "/aspect_memberships/"+this.membership_id
      );
    });

    it('removes the membership id from the contact', function() {
      jasmine.Ajax.install();
      $('.contact_remove-from-aspect',this.contact).trigger('click');
      jasmine.Ajax.requests.mostRecent().response({
        status: 200, // success
        responseText: '{}'
      });
      expect(this.button.attr('data-membership_id')).toBe(undefined);
    });

    it('displays a flash message on errors', function(){
      jasmine.Ajax.install();
      $('.contact_remove-from-aspect',this.contact).trigger('click');
      jasmine.Ajax.requests.mostRecent().response({
        status: 400, // fail
      });
      expect($('[id^="flash"]')).toBeErrorFlashMessage(
        Diaspora.I18n.t(
          'contacts.error_remove',
          {name: this.contact.find('.name').text()}
        )
      );
    });

    it('changes the appearance of the contact', function() {
      expect(this.button.hasClass('contact_add-to-aspect')).toBeFalsy;
      expect(this.button.hasClass('circled-cross')).toBeFalsy;
      expect(this.contact.hasClass('in_aspect')).toBeFalsy;
      expect(this.button.hasClass('contact_remove-from-aspect')).toBeTruethy;
      expect(this.button.hasClass('circled-plus')).toBeTruethy;
      expect(this.button.attr('data-original-title')).toBe(
        Diaspora.I18n.t('contacts.remove_contact')
      );

      jasmine.Ajax.install();
      $('.contact_remove-from-aspect',this.contact).trigger('click');
      jasmine.Ajax.requests.mostRecent().response({
        status: 200, // success
        responseText: '{}'
      });

      expect(this.button.hasClass('contact_add-to-aspect')).toBeTruethy;
      expect(this.button.hasClass('circled-cross')).toBeTruethy;
      expect(this.contact.hasClass('in_aspect')).toBeTruethy;
      expect(this.button.hasClass('contact_remove-from-aspect')).toBeFalsy;
      expect(this.button.hasClass('circled-plus')).toBeFalsy;
      expect(this.button.attr('data-original-title')).toBe(
        Diaspora.I18n.t('contacts.add_contact')
      );
    });
  });

  context('search contact list', function() {
    beforeEach(function() {
      this.searchinput = $('#contact_list_search');
      this.username = $('.stream_element .name').first().text();
    });

    it('filters the contact list by name', function() {
      expect($('.stream_element').length).toBeGreaterThan(1);
      this.searchinput.val(this.username);
      this.searchinput.trigger('keyup');
      expect($('.stream_element:visible').length).toBe(1);
      expect($('.stream_element:visible .name').first().text()).toBe(this.username);
    });
  });

});
