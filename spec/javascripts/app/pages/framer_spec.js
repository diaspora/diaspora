describe("app.pages.Framer", function(){
  beforeEach(function(){
    loginAs(factory.user())
    app.frame = new factory.statusMessage();
    this.page = new app.pages.Framer();
  });

  it("passes the model down to the post view", function(){
    expect(this.page.postView().model).toBe(app.frame)
  });

  describe("navigation on save", function(){
    it("navigates to the current user's profile page", function(){
      spyOn(app.router, "navigate")
      this.page.model.trigger("sync")
      expect(app.router.navigate).toHaveBeenCalled()
    })

    // want a spec here for the bookmarklet case
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.page.render();
    });

    it("saves the model when you click done",function(){
      spyOn(app.frame, "save");
      this.page.$("button.done").click();
      expect(app.frame.save).toHaveBeenCalled();
    });

    it("makes and renders a new smallFrame when the template is changed", function(){
      expect(app.frame.get("frame_name")).not.toBe("night") //pre conditions, yo
      this.page.$("a.mood[data-mood=Night]").click()
      expect(app.frame.get("frame_name")).toBe("Night")
    })
  });
});
