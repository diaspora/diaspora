describe("app.pages.PostNew", function(){
  beforeEach(function(){
    this.page = new app.pages.PostNew()
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.page.render();
    })

    describe("clicking next", function(){
      beforeEach(function(){
        spyOn(app.router, "navigate")
        spyOn(this.page.postForm, "setModelAttributes")
        this.page.$("button.next").click()
      })

      it("calls tells the form to set the models attributes", function(){
        expect(this.page.postForm.setModelAttributes).toHaveBeenCalled();
      });

      it("stores a reference to the form as app.composer" , function(){
        expect(this.page.model).toBeDefined()
        expect(app.frame).toBe(this.page.model)
      });

      it("navigates to the framer", function(){
        expect(app.router.navigate).toHaveBeenCalledWith("framer", true)
      });
    })
  })
});