describe("app.views.OEmbed", function(){
  beforeEach(function(){
    this.statusMessage = factory.statusMessage({
      "o_embed_cache":{
        "data":{
          "html":"some html"
        }
      }
    })

    this.view = new app.views.OEmbed({model : this.statusMessage})
  })

  describe("rendering", function(){
    it("provides oembed html from the model response", function(){
      this.view.render()
      expect(this.view.$el.html()).toContain("some html")
    })
  })

  describe("presenter", function(){
    it("provides oembed html from the model", function(){
      expect(this.view.presenter().o_embed_html).toContain("some html")
    })

    it("does not provide oembed html from the model response if none is present", function(){
      this.statusMessage.set({"o_embed_cache" : null})
      expect(this.view.presenter().o_embed_html).toBe("");
    })
  })
})