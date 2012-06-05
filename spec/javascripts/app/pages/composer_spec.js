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
        this.page.$("input.next").click()
        expect(this.navigateSpy).toHaveBeenCalledWith("framer", true)
      });

      describe(" setting the model's attributes from the various form fields", function(){
        beforeEach(function(){
          this.page.$("form .text").val("Oh My")
        })

        it("instantiates a post on form submit", function(){
          this.page.$("input.next").click()
          waitsFor(function(){ return this.navigateSpy.wasCalled })
          runs(function(){
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