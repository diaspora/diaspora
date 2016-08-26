describe("app.pages.GettingStarted", function() {
  beforeEach(function() {
    spec.loadFixture("getting_started");
    app.aspects = new app.collections.Aspects([factory.aspect()]);

    this.view = new app.pages.GettingStarted({
      inviter: factory.person()
    });
  });

  it("renders aspect membership dropdown", function() {
    this.view.render();
    expect($("ul.dropdown-menu.aspect_membership").length).toEqual(1);
  });
});
