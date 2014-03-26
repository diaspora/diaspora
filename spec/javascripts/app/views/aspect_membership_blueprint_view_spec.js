describe("app.views.AspectMembershipBlueprint", function(){
  var resp_success = {status: 200, responseText: '{}'};
  var resp_fail = {status: 400};

  beforeEach(function() {
    spec.loadFixture("aspect_membership_dropdown_blueprint");
    this.view = new app.views.AspectMembershipBlueprint();
    this.person_id = $('.dropdown_list').data('person_id');
    this.person_name = $('.dropdown_list').data('person-short-name');

    Diaspora.I18n.load({
      aspect_dropdown: {
        started_sharing_with: 'you started sharing with <%= name %>',
        stopped_sharing_with: 'you stopped sharing with <%= name %>',
        error: 'unable to add <%= name %>',
        error_remove: 'unable to remove <%= name %>'
      }
    });
  });

  context('adding to aspects', function() {
    beforeEach(function() {
      this.newAspect = $('li:not(.selected)');
      this.newAspectId = this.newAspect.data('aspect_id');
    });

    it('marks the aspect as selected', function() {
      this.newAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().response(resp_success);

      expect(this.newAspect.attr('class')).toContain('selected');
    });

    it('displays flash message when added to first aspect', function() {
      spec.content().find('li').removeClass('selected');
      this.newAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().response(resp_success);

      expect($('[id^="flash"]')).toBeSuccessFlashMessage(
        Diaspora.I18n.t('aspect_dropdown.started_sharing_with', {name: this.person_name})
      );
    });

    it('displays an error when it fails', function() {
      this.newAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().response(resp_fail);

      expect($('[id^="flash"]')).toBeErrorFlashMessage(
        Diaspora.I18n.t('aspect_dropdown.error', {name: this.person_name})
      );
    });
  });

  context('removing from aspects', function(){
    beforeEach(function() {
      this.oldAspect = $('li.selected').first();
      this.oldMembershipId = this.oldAspect.data('membership_id');
    });

    it('marks the aspect as unselected', function(){
      this.oldAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().response(resp_success);

      expect(this.oldAspect.attr('class')).not.toContain('selected');
    });

    it('displays a flash message when removed from last aspect', function() {
      spec.content().find('li.selected:last').removeClass('selected');
      this.oldAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().response(resp_success);

      expect($('[id^="flash"]')).toBeSuccessFlashMessage(
        Diaspora.I18n.t('aspect_dropdown.stopped_sharing_with', {name: this.person_name})
      );
    });

    it('displays an error when it fails', function() {
      this.oldAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().response(resp_fail);

      expect($('[id^="flash"]')).toBeErrorFlashMessage(
        Diaspora.I18n.t('aspect_dropdown.error_remove', {name: this.person_name})
      );
    });
  });

  context('summary text in the button', function() {
    beforeEach(function() {
      this.btn = $('div.button.toggle');
      this.btn.text(""); // reset
      this.view.dropdown = $('ul.dropdown_list');
    });

    it('shows "no aspects" when nothing is selected', function() {
      $('li[data-aspect_id]').removeClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(Diaspora.I18n.t('aspect_dropdown.toggle.zero'));
    });

    it('shows "all aspects" when everything is selected', function() {
      $('li[data-aspect_id]').addClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(Diaspora.I18n.t('aspect_dropdown.all_aspects'));
    });

    it('shows the name of the selected aspect ( == 1 )', function() {
      var list = $('li[data-aspect_id]');
      list.removeClass('selected'); // reset
      list.eq(1).addClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(list.eq(1).text());
    });

    it('shows the number of selected aspects ( > 1)', function() {
      var list = $('li[data-aspect_id]');
      list.removeClass('selected'); // reset
      $([list.eq(1), list.eq(2)]).addClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(Diaspora.I18n.t('aspect_dropdown.toggle', { 'count':2 }));
    });
  });
});
