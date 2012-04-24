describe("app.views.SmallFrame", function(){
  beforeEach(function(){
    this.model = factory.post({
      photos : [
        factory.photoAttrs({sizes : {large : "http://tieguy.org/me.jpg"}}),
        factory.photoAttrs({sizes : {large : "http://whatthefuckiselizabethstarkupto.com/none_knows.gif"}}) //SIC
      ],

      "o_embed_cache":{
        "data":{
          "html":"this is a crazy oemebed lol"
        }
      }
    })

    this.view = new app.views.SmallFrame({model : this.model})
  })

  it("passes the model down to the oembed view", function(){
    expect(this.view.oEmbedView().model).toBe(this.model)
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    });

    it("has the oembed", function(){ //integration test
      expect($.trim(this.view.$(".embed-frame").text())).toContain("this is a crazy oemebed lol")
    })
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
