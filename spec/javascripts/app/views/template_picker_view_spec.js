describe("app.views.TemplatePicker", function(){
  beforeEach(function(){
    this.model = factory.statusMessage({templateName: undefined})
    this.view = new app.views.TemplatePicker({model : this.model })
  })

  describe("initialization", function(){
    it("sets the post_type of the model to 'status' by default", function(){
      expect(this.view.model.get("templateName")).toBe("status")
    })
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    })

    it("selects the model's templateName from the dropdown", function(){
      expect(this.view.$("select[name=template]").val()).toBe("status")
    })

    it("changes the templateName on the model when is is selected", function(){
      this.view.$("select[name=template]").val("note")
      this.view.$("select[name=template]").trigger("change")
      expect(this.model.get("templateName")).toBe('note')
    })
  })
})