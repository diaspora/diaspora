describe("app.views.AspectMembership", function(){
  var success = {status: 200, responseText: "{}"};
  var resp_fail = {status: 400, responseText: "error message"};

  beforeEach(function() {
    var contact = factory.contact();
    this.person = contact.person;
    this.personName = this.person.get("name");
    var aspectAttrs = contact.aspectMemberships.at(0).get("aspect");
    app.aspects = new app.collections.Aspects([factory.aspect(aspectAttrs), factory.aspect()]);
    this.view = new app.views.AspectMembership({person: this.person});
    this.view.render();
    spec.content().append($("<div id='flash-container'/>"));
    app.flashMessages = new app.views.FlashMessages({el: spec.content().find("#flash-container")});
  });

  context('adding to aspects', function() {
    beforeEach(function() {
      this.newAspect = this.view.$("li:not(.selected)");
      this.newAspectId = this.newAspect.data('aspect_id');
    });

    it('marks the aspect as selected', function() {
      this.newAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: JSON.stringify({
          id: factory.id.next(),
          aspect: app.aspects.at(1).attributes
        })
      });

      expect(this.view.$("li[data-aspect_id=" + this.newAspectId + "]").attr("class")).toContain("selected");
    });

    it('displays flash message when added to first aspect', function() {
      this.view.$("li").removeClass("selected");
      this.newAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().respondWith(success);

      expect(spec.content().find(".flash-message")).toBeSuccessFlashMessage(
        Diaspora.I18n.t("aspect_dropdown.started_sharing_with", {name: this.personName})
      );
    });

    it("triggers aspect_membership:create", function() {
      spyOn(app.events, "trigger");
      this.view.$("li").removeClass("selected");
      this.newAspect.trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith(success);
      expect(app.events.trigger).toHaveBeenCalledWith("aspect_membership:create", {
        membership: {aspectId: this.newAspectId, personId: this.person.id},
        startSharing: true
      });
    });

    it('displays an error when it fails', function() {
      spyOn(app.flashMessages, "handleAjaxError").and.callThrough();
      this.newAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().respondWith(resp_fail);

      expect(app.flashMessages.handleAjaxError).toHaveBeenCalled();
      expect(app.flashMessages.handleAjaxError.calls.argsFor(0)[0].responseText).toBe("error message");
      expect(spec.content().find(".flash-message")).toBeErrorFlashMessage("error message");
    });
  });

  context('removing from aspects', function(){
    beforeEach(function() {
      this.oldAspect = this.view.$("li.selected").first();
      this.oldAspectId = this.oldAspect.data("aspect_id");
    });

    it('marks the aspect as unselected', function(){
      this.oldAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().respondWith(success);

      expect(this.view.$("li[data-aspect_id=" + this.oldAspectId + "]").attr("class")).not.toContain("selected");
    });

    it('displays a flash message when removed from last aspect', function() {
      this.oldAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().respondWith(success);

      expect(spec.content().find(".flash-message")).toBeSuccessFlashMessage(
        Diaspora.I18n.t("aspect_dropdown.stopped_sharing_with", {name: this.personName})
      );
    });

    it("triggers aspect_membership:destroy", function() {
      spyOn(app.events, "trigger");
      this.oldAspect.trigger("click");
      jasmine.Ajax.requests.mostRecent().respondWith(success);
      expect(app.events.trigger).toHaveBeenCalledWith("aspect_membership:destroy", {
        membership: {aspectId: this.oldAspectId, personId: this.person.id},
        stopSharing: true
      });
    });

    it('displays an error when it fails', function() {
      spyOn(app.flashMessages, "handleAjaxError").and.callThrough();
      this.oldAspect.trigger('click');
      jasmine.Ajax.requests.mostRecent().respondWith(resp_fail);

      expect(app.flashMessages.handleAjaxError).toHaveBeenCalled();
      expect(app.flashMessages.handleAjaxError.calls.argsFor(0)[0].responseText).toBe("error message");
      expect(spec.content().find(".flash-message")).toBeErrorFlashMessage("error message");
    });
  });
});
