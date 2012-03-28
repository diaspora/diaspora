describe("app.views.Post.Night", function(){
  beforeEach(function(){
    this.post = factory.post()
    this.view = new app.views.Post.Night({model : this.post})
  })

  describe("rendering", function(){
    it("is happy", function(){
      this.view.render()
    })
  })
})