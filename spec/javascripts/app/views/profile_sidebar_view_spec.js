
describe("app.views.ProfileSidebar", function() {
  beforeEach(function() {
    this.model = factory.personWithProfile({
      diaspora_id: "alice@umbrella.corp",
      name: "Project Alice",
      relationship: 'mutual',
      profile: {
        bio: "confidential",
        location: "underground",
        gender: "female",
        birthday: "2012-09-14",
        tags: ['zombies', 'evil', 'blood', 'gore']

      }
    });
    this.view = new app.views.ProfileSidebar({model: this.model});

    loginAs(factory.userAttrs());
  });

  context("#presenter", function() {
    it("contains necessary elements", function() {
      console.log(this.view.presenter());
      expect(this.view.presenter()).toEqual(jasmine.objectContaining({
        relationship: 'mutual',
        do_profile_btns: true,
        do_profile_info: true,
        is_sharing: true,
        is_receiving: true,
        is_mutual: true,
        is_not_blocked: true,
        profile: jasmine.objectContaining({
          bio: "confidential",
          location: "underground",
          gender: "female",
          birthday: "2012-09-14"
        })
      }));
    });
  });
});
