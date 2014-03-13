describe("app.views.AspectMembershipBlueprint", function(){
  beforeEach(function() {
    spec.loadFixture("aspect_membership_dropdown_blueprint");
    this.view = new app.views.AspectMembershipBlueprint();
    this.person_id = $('.dropdown_list').data('person_id');
  });

  it('attaches to the aspect selector', function(){
    spyOn($.fn, 'on');
    view = new app.views.AspectMembership();

    expect($.fn.on).toHaveBeenCalled();
  });

  context('adding to aspects', function() {
    beforeEach(function() {
      this.newAspect = $('li:not(.selected)');
      this.newAspectId = this.newAspect.data('aspect_id');
    });

    it('calls "addMembership"', function() {
       spyOn(this.view, "addMembership");
       this.newAspect.trigger('click');

       expect(this.view.addMembership).toHaveBeenCalledWith(this.person_id, this.newAspectId);
    });

    it('tries to create a new AspectMembership', function() {
      spyOn(app.models.AspectMembership.prototype, "save");
      this.view.addMembership(1, 2);

      expect(app.models.AspectMembership.prototype.save).toHaveBeenCalled();
    });

    it('displays an error when it fails', function() {
      spyOn(this.view, "_displayError");
      spyOn(app.models.AspectMembership.prototype, "save").andCallFake(function() {
        this.trigger('error');
      });

      this.view.addMembership(1, 2);

      expect(this.view._displayError).toHaveBeenCalledWith('aspect_dropdown.error');
    });
  });

  context('removing from aspects', function(){
    beforeEach(function() {
      this.oldAspect = $('li.selected');
      this.oldMembershipId = this.oldAspect.data('membership_id');
    });

    it('calls "removeMembership"', function(){
      spyOn(this.view, "removeMembership");
      this.oldAspect.trigger('click');

      expect(this.view.removeMembership).toHaveBeenCalledWith(this.oldMembershipId);
    });

    it('tries to destroy an AspectMembership', function() {
      spyOn(app.models.AspectMembership.prototype, "destroy");
      this.view.removeMembership(1);

      expect(app.models.AspectMembership.prototype.destroy).toHaveBeenCalled();
    });

    it('displays an error when it fails', function() {
      spyOn(this.view, "_displayError");
      spyOn(app.models.AspectMembership.prototype, "destroy").andCallFake(function() {
        this.trigger('error');
      });

      this.view.removeMembership(1);

      expect(this.view._displayError).toHaveBeenCalledWith('aspect_dropdown.error_remove');
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
