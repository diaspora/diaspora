describe("app.views.Post.SmallFrame", function(){
  beforeEach(function(){
    this.model = factory.post({
      photos : [
        factory.photoAttrs({sizes : {
           large : "http://tieguy.org/me.jpg"
          },
          dimensions : {
            width : 100,
            height : 200 }
        }),
        factory.photoAttrs({sizes : {large : "http://whatthefuckiselizabethstarkupto.com/none_knows.gif"}}) //SIC
      ],

      "o_embed_cache":{
        "data":{
          "html":"this is a crazy oemebed lol"
        }
      }
    })

    this.view = new app.views.Post.SmallFrame({model : this.model})
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

  describe("redirecting to a post", function(){
    beforeEach(function(){
      app.page = { editMode : false }
      app.router = new app.Router()
      window.gon.preloads = {}
      spyOn(app.router, "navigate")
    })

    it("redirects", function() {
      this.view.goToPost()
      expect(app.router.navigate).toHaveBeenCalled()
    })
  })
});
