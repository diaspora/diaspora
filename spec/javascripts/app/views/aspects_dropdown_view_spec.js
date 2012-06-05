describe("app.views.AspectsDropdown", function () {
  function selectedAspects(view){
    return _.pluck(view.$("input.aspect_ids").serializeArray(), "value")
  }

  beforeEach(function () {
    loginAs({
      aspects:[
        { id:3, name:"sauce" },
        { id:5, name:"conf" },
        { id:7, name:"lovers" }
      ]
    })

    this.view = new app.views.AspectsDropdown({model:factory.statusMessage({aspect_ids:undefined})})
  })

  describe("rendering", function () {
    beforeEach(function () {
      this.view.render()
    })
    it("sets aspect_ids to 'public' by default", function () {
      expect(this.view.$("input.aspect_ids:checked").val()).toBe("public")
    })

    it("defaults to Public Visibility", function () {
      expect(this.view.$("input.aspect_ids.public")).toBeChecked()
      expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("Public")
    })

    it("sets aspect_ids to 'public'", function () {
      expect(selectedAspects(this.view)).toEqual(["public"])
    })

    it("sets the dropdown title to 'public'", function () {
      expect(this.view.$(".dropdown-toggle .text").text()).toBe("Public")
    })

    describe("setVisibility", function () {
      function checkInput(input){
        input.attr("checked", "checked")
        input.trigger("change")
      }

      function uncheckInput(input){
        input.attr("checked", false)
        input.trigger("change")
      }

      describe("selecting All Aspects", function () {
        beforeEach(function () {
          this.input = this.view.$("input#aspect_ids_all_aspects")
          checkInput(this.input)
        })

        it("calls set aspect_ids to 'all'", function () {
          expect(selectedAspects(this.view)).toEqual(["all_aspects"])
        })

        it("sets the dropdown title to 'public'", function () {
          expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("All Aspects")
        })
      })

      describe("selecting An Aspect", function () {
        beforeEach(function () {
          this.input = this.view.$("input[name='lovers']")
          checkInput(this.input)
        })

        it("sets the dropdown title to the aspect title", function () {
          expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("lovers")
        })

        it("sets aspect_ids to to the aspect id", function () {
          expect(selectedAspects(this.view)).toEqual(["7"])
        })

        describe("selecting another aspect", function () {
          beforeEach(function () {
            this.input = this.view.$("input[name='sauce']")
            checkInput(this.input)
          })

          it("sets aspect_ids to the selected aspects", function () {
            expect(selectedAspects(this.view)).toEqual(["3", "7"])
          })

          it("sets the button text to the number of selected aspects", function () {
            expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("In 2 aspects")
            checkInput(this.view.$("input[name='conf']"))
            expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("In 3 aspects")
            uncheckInput(this.view.$("input[name='conf']"))
            expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("In 2 aspects")
          })

          describe("deselecting another aspect", function () {
            it("removes the clicked aspect", function () {
              expect(selectedAspects(this.view)).toEqual(["3", "7"])
              expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("In 2 aspects")
              uncheckInput(this.view.$("input[name='lovers']"))
              expect(selectedAspects(this.view)).toEqual(["3"])
              expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("sauce")
            })
          })

          describe("selecting all_aspects", function () {
            it("sets aspect_ids to all_aspects", function () {
              expect(selectedAspects(this.view)).toEqual(["3", "7"])
              checkInput(this.view.$("input[name='All Aspects']"))
              expect(selectedAspects(this.view)).toEqual(["all_aspects"])
            })
          })

          describe("selecting public", function () {
            it("sets aspect_ids to public", function () {
              expect(selectedAspects(this.view)).toEqual(["3", "7"])
              checkInput(this.view.$("input[name='Public']"))
              expect(selectedAspects(this.view)).toEqual(["public"])
            })
          })
        })
      })
    })
  })
})