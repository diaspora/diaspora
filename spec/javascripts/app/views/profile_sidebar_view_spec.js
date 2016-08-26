
describe("app.views.ProfileSidebar", function() {
  beforeEach(function() {
    this.model = factory.personWithProfile({
      diaspora_id: "alice@umbrella.corp",
      name: "Project Alice",
      relationship: 'mutual',
      show_profile_info: true,
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
      expect(this.view.presenter()).toEqual(jasmine.objectContaining({
        relationship: 'mutual',
        show_profile_info: true,
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
