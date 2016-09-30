
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

  describe("showMessageModal", function() {
    beforeEach(function() {
      $("body").append("<div id='conversationModal'/>").append(spec.readFixture("conversations_modal"));
    });

    it("calls app.helpers.showModal", function() {
      spyOn(app.helpers, "showModal");
      this.view.showMessageModal();
      expect(app.helpers.showModal);
    });

    it("app.views.ConversationsForm with correct parameterswhen modal is loaded", function() {
      gon.conversationPrefill = [
        {id: 1, name: "diaspora user", handle: "diaspora-user@pod.tld"},
        {id: 2, name: "other diaspora user", handle: "other-diaspora-user@pod.tld"},
        {id: 3, name: "user@pod.tld", handle: "user@pod.tld"}
      ];

      spyOn(app.views.ConversationsForm.prototype, "initialize");
      this.view.showMessageModal();
      $("#conversationModal").trigger("modal:loaded");
      expect(app.views.ConversationsForm.prototype.initialize)
        .toHaveBeenCalledWith({prefill: gon.conversationPrefill});
    });
  });
});
