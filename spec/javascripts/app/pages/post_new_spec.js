describe("app.pages.PostNew", function(){
  beforeEach(function(){
    this.page = new app.pages.PostNew()
  })

  it("renders", function(){
    this.page.render();
  })

  context("when the model receives setFromForm", function(){
    it("it calls mungeAndSave", function(){
      spyOn(this.page.model, "mungeAndSave")
      this.page.model.trigger("setFromForm")
      expect(this.page.model.mungeAndSave).toHaveBeenCalled();
    })
  })
});