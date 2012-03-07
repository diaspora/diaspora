describe("app.views.PostForm", function(){
  beforeEach(function(){
    this.post = new app.models.Post();
    this.view = new app.views.PostForm({model : this.post})
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    })

    describe("submitting a valid form", function(){
      beforeEach(function(){
        this.view.$("form .text").val("Oh My")
      })

      it("instantiates a post on form submit", function(){
        this.view.$("form").submit()
        expect(this.view.model.get("text")).toBe("Oh My")
      })

      it("triggers a  'setFromForm' event", function(){
        var spy = jasmine.createSpy();
        this.view.model.bind("setFromForm", spy);
        this.view.$("form").submit();
        expect(spy).toHaveBeenCalled();
      })
    })
  })
})
