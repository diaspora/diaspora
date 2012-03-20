describe("app.pages.Framer", function(){
  beforeEach(function(){
    loginAs(factory.user())
    app.frame = new factory.statusMessage();
    this.page = new app.pages.Framer();
  });

  describe("rendering", function(){
    beforeEach(function(){
      this.page.render();
    });

    it("saves the model when you click done",function(){
      spyOn(app.frame, "save");
      this.page.$("button.done").click();
      expect(app.frame.save).toHaveBeenCalled();
    });
  });
});