describe("app.views.ServicesSelector", function(){
  beforeEach(function(){
    loginAs(factory.user({
      services : [
        { provider : "fakeBook" }
      ]
    }));

    this.view = new app.views.ServicesSelector();
  });

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render();
    });

    it("displays all services", function(){
      var checkboxes = $(this.view.el).find('input[type="checkbox"]');

      expect(checkboxes.val()).toBe("fakeBook");
    });
  });
});