describe("app.views.TemplatePicker", function(){
  beforeEach(function(){
    this.model = factory.statusMessage({frame_name: undefined})
    this.view = new app.views.TemplatePicker({model : this.model })
  })

  describe("initialization", function(){
    it("sets the frame_name of the model to 'status' by default", function(){
      expect(this.view.model.get("frame_name")).toBe("status")
    })
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    })

    it("selects the model's frame_name from the dropdown", function(){
      expect(this.view.$("select[name=template]").val()).toBe("status")
    })

    it("changes the frame_name on the model when is is selected", function(){
      this.view.$("select[name=template]").val("note")
      this.view.$("select[name=template]").trigger("change")
      expect(this.model.get("frame_name")).toBe('note')
    })
  })
})