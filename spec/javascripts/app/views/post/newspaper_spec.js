describe("app.views.Post.Newspaper", function(){
  beforeEach(function(){
    this.post = factory.post()
    this.view = new app.views.Post.Newspaper({model : this.post})
  })

  describe("rendering", function(){
    it("is happy", function(){
      this.view.render()
    })
  })
})