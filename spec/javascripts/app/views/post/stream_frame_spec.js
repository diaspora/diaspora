describe("app.views.Post.StreamFrame", function(){
  beforeEach(function(){
    this.post = factory.post()
    this.view = new app.views.Post.StreamFrame({model : this.post})
  })

  describe("rendering", function(){
    context("clicking the content", function(){
      it("fetches the interaction pane", function(){
        spyOn(this.post.interactions, "fetch").andReturn(new $.Deferred)
        this.view.render()
        this.view.$('.content').click()
        expect(this.post.interactions.fetch).toHaveBeenCalled()
      })
    })
  })
})