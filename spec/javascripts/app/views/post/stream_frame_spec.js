describe("app.views.Post.StreamFrame", function(){
  beforeEach(function(){
    this.post = factory.post()
    this.stream = new Backbone.Model
    this.view = new app.views.Post.StreamFrame({model : this.post, stream: this.stream })
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    })

    context("clicking the content", function(){
      it("triggers frame interacted", function(){
        var spy = jasmine.createSpy()
        this.stream.on("frame:interacted", spy)
        this.view.$('.content').click()
        expect(spy).toHaveBeenCalledWith(this.post)
      })

    })
  })
});