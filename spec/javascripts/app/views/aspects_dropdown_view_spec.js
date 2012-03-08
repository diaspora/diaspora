describe("app.views.AspectsDropdown", function(){
  beforeEach(function(){
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
        this.view.$("a[data-visibility='public']").click()
      })

      it("calls set aspect_ids to 'public'", function(){
        expect(this.view.$("input.aspect_ids").val()).toBe("public")
      })

      it("sets the dropdown title to 'public'", function(){
        expect(this.view.$(".dropdown-toggle .text").text()).toBe("Public")
      })
    })

    describe("selecting All Aspects", function(){
      beforeEach(function(){
        this.view.$("a[data-visibility='all-aspects']").click()
      })

      it("calls set aspect_ids to 'all'", function(){
        expect(this.view.$("input.aspect_ids").val()).toBe("all_aspects")
      })

      it("sets the dropdown title to 'public'", function(){
        expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("All Aspects")
      })
    })
  })
})