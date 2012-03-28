describe("app.views.AspectsDropdown", function(){
  beforeEach(function(){
    loginAs(factory.user({
      aspects : [
        { id : 3, name : "sauce" },
        { id : 5, name : "conf" },
        { id : 7, name : "lovers" }
      ]
    }))

    this.view = new app.views.AspectsDropdown
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    })

    it("defaults to All Aspects Visibility", function(){
      expect(this.view.$("input.aspect_ids").val()).toBe("all_aspects")
      expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("All Aspects")
    })

    describe("selecting Public", function(){
      beforeEach(function(){
       this.link = this.view.$("a[data-visibility='public']")
       this.link.click()
      })

      it("calls set aspect_ids to 'public'", function(){
        expect(this.view.$("input.aspect_ids").val()).toBe("public")
      })

      it("sets the dropdown title to 'public'", function(){
        expect(this.view.$(".dropdown-toggle .text").text()).toBe("Public")
      })

      it("adds the selected class to the link", function(){
        expect(this.link.parent().hasClass("selected")).toBeTruthy();
      })
    })

    describe("selecting All Aspects", function(){
      beforeEach(function(){
        this.link = this.view.$("a[data-visibility='all-aspects']")
        this.link.click()
      })

      it("calls set aspect_ids to 'all'", function(){
        expect(this.view.$("input.aspect_ids").val()).toBe("all_aspects")
      })

      it("sets the dropdown title to 'public'", function(){
        expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("All Aspects")
      })

      it("adds the selected class to the link", function(){
        expect(this.link.parent().hasClass("selected")).toBeTruthy();
      })
    })


    describe("selecting An Aspect", function(){
      beforeEach(function(){
        this.link = this.view.$("a:contains('lovers')")
        this.link.click()
      })

      it("sets the dropdown title to the aspect title", function(){
        expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("lovers")
      })

      it("adds the selected class to the link", function(){
        expect(this.link.parent().hasClass("selected")).toBeTruthy();
      })

      it("sets aspect_ids to to the aspect id", function(){
        expect(this.view.$("input.aspect_ids").val()).toBe("7")
      })

      describe("selecting another aspect", function(){
        beforeEach(function(){
          this.view.$("a:contains('sauce')").click()
        })

        it("sets aspect_ids to the selected aspects", function(){
          expect(this.view.$("input.aspect_ids").val()).toBe("3,7")
        })

        describe("deselecting another aspect", function(){
          it("removes the clicked aspect", function(){
            expect(this.view.$("input.aspect_ids").val()).toBe("3,7")
            this.view.$("a:contains('lovers')").click()
            expect(this.view.$("input.aspect_ids").val()).toBe("3")
          })
        })

        describe("selecting all_aspects", function(){
          it("sets aspect_ids to all_aspects", function(){
            this.view.$("a[data-visibility='all-aspects']").click()
            expect(this.view.$("input.aspect_ids").val()).toBe("all_aspects")
          })
        })

        describe("selecting public", function(){
          it("sets aspect_ids to public", function(){
            this.view.$("a[data-visibility='public']").click()
            expect(this.view.$("input.aspect_ids").val()).toBe("public")
          })
        })
      })
    })
  })
})