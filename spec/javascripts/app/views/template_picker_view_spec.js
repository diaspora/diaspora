describe("app.views.TemplatePicker", function(){
  beforeEach(function(){
    this.model = factory.statusMessage({frame_name: undefined})
    this.view = new app.views.TemplatePicker({model : this.model })
  })

  describe("initialization", function(){
    it("sets the frame_name of the model to 'Day' by default", function(){
      expect(this.view.model.get("frame_name")).toBe("Day")
    })
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    })

    it("selects the model's frame_name from the dropdown", function(){
      expect(this.view.$(".mood#selected_mood").data("mood")).toBe("Day")
    })

    it("changes the frame_name on the model when is is selected", function(){
      this.view.$(".mood[data-mood=Night]").click()
      expect(this.view.$(".mood#selected_mood").data("mood")).toBe("Night")
      expect(this.model.get("frame_name")).toBe('Night')
    })
  })
})