describe("app.models.Post.TemplatePicker", function(){
  beforeEach(function(){
    this.post = factory.statusMessage({frame_name: undefined, text : "Lol this is a post"})
    this.templatePicker = new app.models.Post.TemplatePicker(this.post)
  })

  describe("getFrameName", function(){
    context("when the model has hella text", function(){
      beforeEach(function(){
        this.post.set({text : window.hipsterIpsumFourParagraphs })
      })

      it("returns Wallpaper", function(){
        expect(this.templatePicker.getFrameName()).toBe("Newspaper")
      })
    })

    context("when the model has photos:", function(){
      context("one photo", function(){
        beforeEach(function(){
          this.post.set({photos : [factory.photoAttrs()]})
        })

        it("returns Wallpaper", function(){
          expect(this.templatePicker.getFrameName()).toBe("Wallpaper")
        })
      })

      context("two photos", function(){
        beforeEach(function(){
          this.post.set({photos : [factory.photoAttrs(), factory.photoAttrs()]})
        })

        it("returns Day", function(){
          expect(this.templatePicker.getFrameName()).toBe("Day")
        })
      })

      it("returns 'Day' by default", function(){
        expect(this.templatePicker.getFrameName()).toBe("Day")
      })
    })
  })
})
