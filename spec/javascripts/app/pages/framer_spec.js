describe("app.pages.Framer", function(){
  beforeEach(function(){
    loginAs(factory.user())
    app.frame = new factory.statusMessage();
    this.page = new app.pages.Framer();
  });

  it("passes the model down to the post view", function(){
    expect(this.page.postView().model).toBe(app.frame)
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

    it("calls navigateNext on save", function(){
      spyOn(this.page, "navigateNext")
      this.page.model.trigger("sync")
      expect(this.page.navigateNext).toHaveBeenCalled()
    })

    it("makes and renders a new smallFrame when the template is changed", function(){
      expect(app.frame.get("frame_name")).not.toBe("night") //pre conditions, yo
      this.page.$("a.mood[data-mood=Night]").click()
      expect(app.frame.get("frame_name")).toBe("Night")
    })
  });
});
