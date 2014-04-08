describe("app.views.AspectMembership", function(){
  beforeEach(function() {
    // mock a dummy aspect dropdown
    spec.loadFixture("aspect_membership_dropdown_bootstrap");
    this.view = new app.views.AspectMembership({el: $('.aspect_membership_dropdown')});
    this.person_id = $('.dropdown-menu').data('person_id');
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

  context('updateSummary', function() {
    beforeEach(function() {
      this.Aspect = $('li:eq(0)');
    });

    it('calls "_toggleCheckbox"', function() {
      spyOn(this.view, "_toggleCheckbox");
      this.view.updateSummary(this.Aspect);

      expect(this.view._toggleCheckbox).toHaveBeenCalledWith(this.Aspect);
    });

    it('calls "_updateButton"', function() {
      spyOn(this.view, "_updateButton");
      this.view.updateSummary(this.Aspect);

      expect(this.view._updateButton).toHaveBeenCalledWith('green');
    });
  });
});
