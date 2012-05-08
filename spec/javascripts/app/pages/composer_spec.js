describe("app.pages.Composer", function(){
  beforeEach(function(){
    this.page = new app.pages.Composer()
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.page.render();
    })

    describe("clicking next", function(){
      beforeEach(function(){
       this.navigateSpy = spyOn(app.router, "navigate")
      })

      it("navigates to the framer", function(){
        this.page.$("button.next").click()
        expect(this.navigateSpy).toHaveBeenCalledWith("framer", true)
      });

      describe(" setting the model's attributes from the various form fields", function(){
        beforeEach(function(){
          this.page.$("form .text").val("Oh My")
          this.page.$("input.aspect_ids").val("public")

          /* appending checkboxes */
          this.page.$(".service-selector").append($("<input/>", {
            value : "fakeBook",
            checked : "checked",
            "class" : "service",
            "type" : "checkbox"
          }))

          this.page.$(".service-selector").append($("<input/>", {
            value : "twitter",
            checked : "checked",
            "class" : "service",
            "type" : "checkbox"
          }))
        })

        it("instantiates a post on form submit", function(){
          this.page.$("button.next").click()
          waitsFor(function(){ return this.navigateSpy.wasCalled })
          runs(function(){
            expect(this.page.model.get("aspect_ids")).toBe("public")
            expect(this.page.model.get("services").length).toBe(2)
            expect(this.page.model.get("text")).toBe("Oh My")
          })
        })
      });
    })
  })

  it("stores a reference to the form as app.composer" , function(){
    expect(this.page.model).toBeDefined()
    expect(app.frame).toBe(this.page.model)
  });
});