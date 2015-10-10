describe("app.views.AspectMembership", function(){
  var success = {status: 200, responseText: "{}"};
  var resp_fail = {status: 400};

  beforeEach(function() {
    // mock a dummy aspect dropdown
    spec.loadFixture("aspect_membership_dropdown");
    this.view = new app.views.AspectMembership({el: $('.aspect_membership_dropdown')});
    this.view.$el.append($("<div id='flash-container'/>"));
    app.flashMessages = new app.views.FlashMessages({ el: this.view.$("#flash-container") });
    this.personId = $(".dropdown-menu").data("person_id");
    this.personName = $(".dropdown-menu").data("person-short-name");
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
      jasmine.Ajax.requests.mostRecent().respondWith(success);

      expect(this.newAspect.attr('class')).toContain('selected');
    });

    it('displays flash message when added to first aspect', function() {
      spec.content().find('li').removeClass('selected');
      this.newAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().respondWith(success);

      expect(this.view.$(".flash-message")).toBeSuccessFlashMessage(
        Diaspora.I18n.t("aspect_dropdown.started_sharing_with", {name: this.personName})
      );
    });

    it("triggers aspect_membership:create", function() {
      spyOn(app.events, "trigger");
      spec.content().find("li").removeClass("selected");
      this.newAspect.trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith(success);
      expect(app.events.trigger).toHaveBeenCalledWith("aspect_membership:create", {
        membership: {aspectId: this.newAspectId, personId: this.personId},
        startSharing: true
      });
    });

    it('displays an error when it fails', function() {
      this.newAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().respondWith(resp_fail);

      expect(this.view.$(".flash-message")).toBeErrorFlashMessage(
        Diaspora.I18n.t("aspect_dropdown.error", {name: this.personName})
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
      jasmine.Ajax.requests.mostRecent().respondWith(success);

      expect(this.oldAspect.attr('class')).not.toContain('selected');
    });

    it('displays a flash message when removed from last aspect', function() {
      spec.content().find('li.selected:last').removeClass('selected');
      this.oldAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().respondWith(success);

      expect(this.view.$(".flash-message")).toBeSuccessFlashMessage(
        Diaspora.I18n.t("aspect_dropdown.stopped_sharing_with", {name: this.personName})
      );
    });

    it("triggers aspect_membership:destroy", function() {
      spyOn(app.events, "trigger");
      spec.content().find("li.selected:last").removeClass("selected");
      this.oldAspect.trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith(success);
      expect(app.events.trigger).toHaveBeenCalledWith("aspect_membership:destroy", {
        membership: {aspectId: this.oldAspect.data("aspect_id"), personId: this.personId},
        stopSharing: true
      });
    });

    it('displays an error when it fails', function() {
      this.oldAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().respondWith(resp_fail);

      expect(this.view.$(".flash-message")).toBeErrorFlashMessage(
        Diaspora.I18n.t("aspect_dropdown.error_remove", {name: this.personName})
      );
    });
  });

  context('button summary text', function() {
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

      expect(this.view._updateButton).toHaveBeenCalledWith("btn-success");
    });
  });
});
