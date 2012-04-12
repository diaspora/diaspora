describe("app.views.TemplatePicker", function(){
  beforeEach(function(){
    this.model = factory.statusMessage({frame_name: undefined})
    this.view = createView(this.model)
  })

  function createView(model){
    return new app.views.TemplatePicker({model : model })
  }

  describe("initialization", function(){
    context("when the model has photos:", function(){
      context("one photo", function(){
        beforeEach(function(){
          this.model.set({photos : [factory.photoAttrs()]})
        })

        it("sets the frame name to Wallpaper", function(){
          createView(this.model)
          expect(this.model.get("frame_name")).toBe("Wallpaper")
        })
      })

      context("two photos", function(){
        beforeEach(function(){
          this.model.set({photos : [factory.photoAttrs(), factory.photoAttrs()]})
        })

        it("sets the frame name to Wallpaper", function(){
          createView(this.model)
          expect(this.model.get("frame_name")).toBe("Day")
        })
      })
    })

    it("sets the frame_name of the model to 'Day' by default", function(){
      createView(this.model)
      expect(this.model.get("frame_name")).toBe("Day")
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