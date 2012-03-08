describe("app.views.AspectsDropdown", function(){
  beforeEach(function(){
    this.view = new app.views.AspectsDropdown
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    })

    describe("selecting Public", function(){
      it("calls set aspect_ids to 'public'", function(){
        this.view.$("a[data-visibility='public']").click()
        expect(this.view.$("input.aspect_ids").val()).toBe("public")
      })
    })

    describe("selecting All Aspects", function(){
      it("calls set aspect_ids to 'all'", function(){
        this.view.$("a[data-visibility='all-aspects']").click()
        expect(this.view.$("input.aspect_ids").val()).toBe("all_aspects")
      })
    })
  })
})