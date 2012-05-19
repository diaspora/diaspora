describe("app.pages.Framer", function(){
  beforeEach(function(){
    loginAs(factory.user())
    app.frame = new factory.statusMessage({frame_name: undefined});

    this.page = new app.pages.Framer();
    this.model = this.page.model
    expect(this.model).toBe(app.frame) //uses global state of app.frame :/
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

  describe("initialization", function(){
    it("calls setFrameName on the model when there is no frame_name", function(){
      spyOn(this.model, 'setFrameName')
      this.model.unset("frame_name")
      new app.pages.Framer()
      expect(this.model.setFrameName).toHaveBeenCalled()
    })

    it("sets the frame_name of the model to 'Day' by default", function(){ //jasmine integration test, arguably unnecessary
      expect(this.model.get("frame_name")).toBe("Day")
    })
  })


  describe("rendering", function(){
    beforeEach(function(){
      this.page.render();
    });

    it("saves the model when you click done",function(){
      spyOn(app.frame, "save");
      this.page.$("input.done").click();
      expect(app.frame.save).toHaveBeenCalled();
    });

    describe("setting the model's attributes from the various form fields", function(){
      beforeEach(function(){
        this.page.$("input.mood").attr("checked", false) //radio button hax
        expect(app.frame.get("frame_name")).not.toBe("Night")
        this.page.$("input.aspect_ids").val("public")
        this.page.$("input[value='Night']").attr("checked", "checked")
        this.page.$("input.services[value=facebook]").attr("checked", "checked")
        this.page.$("input.services[value=twitter]").attr("checked", "checked")
      })

      it("instantiates a post on form submit", function(){
        this.page.$("input").trigger("change") //runs setFormAttrs
        waitsFor(function(){
          return  this.page.model.get("frame_name") == "Night"
        })

        runs(function(){
          expect(this.page.model.get("aspect_ids")).toEqual(["public"])
          expect(this.page.model.get("services")).toEqual(["facebook", "twitter"])
          expect(this.page.model.get("frame_name")).toBe("Night")
        })
      })
    });
  });
});
