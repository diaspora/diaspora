describe("app.views.ServicesSelector", function(){
  beforeEach(function(){
    loginAs({
      services : [
        { provider : "facebook" }
      ]
    });

    this.view = new app.views.ServicesSelector();
  });

  describe("rendering", function(){
    beforeEach(function(){
      this.view.setElement("#jasmine_content")
      this.view.render();
    });

    it("displays all services", function(){
      var checkboxes = $(this.view.el).find('input[type="checkbox"]');
      expect(checkboxes.val()).toBe("facebook");
    });

    // this tests the crazy css we have in a bassackwards way
    // check out toggling the services on the new publisher and make sure it works if you change stuff.
    it("selects the checkbox when the image is clicked", function(){
      expect($("label[for=service_toggle_facebook]").css("opacity")).toBeLessThan(0.8) //floating point weirdness, be safe.
      this.view.$("input[value='facebook']").select()

        waitsFor(function(){
          return $("label[for=service_toggle_facebook]").css("opacity") == 1
      })
    })
  });
});