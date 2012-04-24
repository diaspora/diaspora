describe("app.views.SmallFrame", function(){
  beforeEach(function(){
    this.model = factory.post({
      photos : [
        factory.photoAttrs({sizes : {large : "http://tieguy.org/me.jpg"}}),
        factory.photoAttrs({sizes : {large : "http://whatthefuckiselizabethstarkupto.com/none_knows.gif"}}) //SIC
      ]
    })
    this.view = new app.views.SmallFrame({model : this.model})
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    });
  })

  describe("photos", function() {
    // ratio pending...
  })

  describe("redirecting to a post", function(){
    beforeEach(function(){
      app.page = {editMode : false}
      app.router = new app.Router()
      spyOn(app.router, "navigate")
    })

    it("redirects", function() {
      this.view.goToPost()
      expect(app.router.navigate).toHaveBeenCalled()
    })

    it("doesn't redirect if the page is in edit mode, and instead favorites the post", function() {
      app.page = {editMode : true}

      spyOn(this.view, "favoritePost")
      this.view.goToPost()
      expect(app.router.navigate).not.toHaveBeenCalled()
      expect(this.view.favoritePost).toHaveBeenCalled()
    })
  })
});
