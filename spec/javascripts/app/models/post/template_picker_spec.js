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

      it("returns Typist", function(){
        expect(this.templatePicker.getFrameName()).toBe("Typist")
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

        it("returns Vanilla", function(){
          expect(this.templatePicker.getFrameName()).toBe("Vanilla")
        })
      })

      it("returns 'Vanilla' by default", function(){
        expect(this.templatePicker.getFrameName()).toBe("Vanilla")
      })
    })
  })
})
