
describe("app.views.ProfileHeader", function() {
  beforeEach(function() {
    this.model = factory.personWithProfile({
      diaspora_id: "my@pod",
      name: "User Name",
      relationship: 'mutual',
      profile: { tags: ['test'] }
    });
    this.view = new app.views.ProfileHeader({model: this.model});
    loginAs(factory.userAttrs());
  });

  describe("initialize", function() {
    it("calls #render when the model changes", function() {
      spyOn(app.views.ProfileHeader.prototype, "render");
      this.view.initialize();
      expect(app.views.ProfileHeader.prototype.render).not.toHaveBeenCalled();
      this.view.model.trigger("change");
      expect(app.views.ProfileHeader.prototype.render).toHaveBeenCalled();
    });

    it("calls #mentionModalLoaded on modal:loaded", function() {
      spec.content().append("<div id='mentionModal'></div>");
      spyOn(app.views.ProfileHeader.prototype, "mentionModalLoaded");
      this.view.initialize();
      expect(app.views.ProfileHeader.prototype.mentionModalLoaded).not.toHaveBeenCalled();
      $("#mentionModal").trigger("modal:loaded");
      expect(app.views.ProfileHeader.prototype.mentionModalLoaded).toHaveBeenCalled();
    });

    it("calls #mentionModalHidden on hidden.bs.modal", function() {
      spec.content().append("<div id='mentionModal'></div>");
      spyOn(app.views.ProfileHeader.prototype, "mentionModalHidden");
      this.view.initialize();
      expect(app.views.ProfileHeader.prototype.mentionModalHidden).not.toHaveBeenCalled();
      $("#mentionModal").trigger("hidden.bs.modal");
      expect(app.views.ProfileHeader.prototype.mentionModalHidden).toHaveBeenCalled();
    });
  });

  context("#presenter", function() {
    it("contains necessary elements", function() {
      expect(this.view.presenter()).toEqual(jasmine.objectContaining({
        diaspora_id: "my@pod",
        name: "User Name",
        is_blocked: false,
        is_own_profile: false,
        has_tags: true,
        show_profile_btns: true,
        relationship: 'mutual',
        is_sharing: true,
        is_receiving: true,
        is_mutual: true,
        profile: jasmine.objectContaining({
          tags: ['test']
        })
      }));
    });
  });
});
