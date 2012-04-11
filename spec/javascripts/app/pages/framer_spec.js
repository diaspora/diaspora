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

    it("navigates on save", function(){
      spyOn(app.router, "navigate")
      this.page.model.trigger("sync")
      expect(app.router.navigate).toHaveBeenCalled()
    })

    it("makes and renders a new post view when the template is changed", function(){
      expect(app.frame.get("frame_name")).not.toBe("Night") //pre conditions, yo
      this.page.$("a.mood[data-mood=Night]").click()
      expect(app.frame.get("frame_name")).toBe("Night")
      expect(this.page.$("article")).toHaveClass("night")
    })
  });
});
