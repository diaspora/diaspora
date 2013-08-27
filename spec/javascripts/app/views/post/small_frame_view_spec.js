describe("app.views.Post.SmallFrame", function(){
  var open_graph_cache = {
    "url": "http://example.com/articles/123",
    "title": "Example title",
    "description": "Test description",
    "image": "http://example.com/thumb.jpg",
    "ob_type": "article"
  };

  var o_embed_cache = {
    "data":{
      "html":"this is a crazy oemebed lol"
    }
  };

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
      o_embed_cache: o_embed_cache,
      open_graph_cache: open_graph_cache
    })

    this.view = new app.views.Post.SmallFrame({model : this.model})
  })

  it("passes the model down to the oembed view", function(){
    expect(this.view.oEmbedView().model).toBe(this.model)
  })

  it("passes the model down to the opengraph view", function(){
    expect(this.view.openGraphView().model).toBe(this.model)
  })

  describe("rendering with oembed and opengraph", function(){
    beforeEach(function(){
      this.view.render()
    });

    it("has the oembed", function(){ //integration test
      expect($.trim(this.view.$(".embed-frame").text())).toContain(o_embed_cache.data.html)
    })

    it("doesn't have opengraph preview", function(){
      expect($.trim(this.view.$(".embed-frame").text())).not.toContain(open_graph_cache.title)
    })
  })

  describe("rendering with opengraph only", function(){
    beforeEach(function(){
      this.view = new app.views.Post.SmallFrame({
        model : factory.post({
          open_graph_cache: open_graph_cache
        })
      })
      this.view.render()
    });

    it("displays opengraph preview", function(){
      expect($.trim(this.view.$(".open-graph-frame").text())).toContain(open_graph_cache.title)
    });
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
