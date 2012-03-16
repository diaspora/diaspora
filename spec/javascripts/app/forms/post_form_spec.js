describe("app.forms.Post", function(){
  beforeEach(function(){
    this.post = new app.models.Post();
    this.view = new app.forms.Post({model : this.post})
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    })

    describe("submitting a valid form", function(){
      beforeEach(function(){
        this.view.$("form #text_with_markup").val("Oh My")
        this.view.$("form .aspect_ids").val("public")

        /* appending checkboxes */
        this.view.$(".new-post").append($("<input/>", {
          value : "fakeBook",
          checked : "checked",
          "class" : "service",
          "type" : "checkbox"
        }))

        this.view.$(".new-post").append($("<input/>", {
          value : "twitter",
          checked : "checked",
          "class" : "service",
          "type" : "checkbox"
        }))
      })

      it("instantiates a post on form submit", function(){
        this.view.$(".new-post").submit()
        expect(this.view.model.get("text")).toBe("Oh My")
        expect(this.view.model.get("aspect_ids")).toBe("public")
        expect(this.view.model.get("services").length).toBe(2)
      })

      it("triggers a  'setFromForm' event", function(){
        var spy = jasmine.createSpy();
        this.view.model.bind("setFromForm", spy);
        this.view.$(".new-post").submit();
        expect(spy).toHaveBeenCalled();
      })
    })
  })
})
