describe("app.views.Post.StreamFrame", function(){
  beforeEach(function(){
    this.post = factory.post()
    this.stream = new Backbone.Model
    this.view = new app.views.Post.StreamFrame({model : this.post, stream: this.stream })
  });

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    });

    context("clicking the content", function(){
      it("triggers frame interacted", function(){
        var spy = jasmine.createSpy()
        this.stream.on("frame:interacted", spy)
        this.view.$('.content').click()
        expect(spy).toHaveBeenCalledWith(this.post)
      })
    })
  });

  describe("going to a post", function(){
    beforeEach(function(){
      this.view.render()
    })

    context("clicking the permalink", function(){
      it("calls goToPost on the smallFrame view", function(){
        spyOn(app.router, "navigate").andReturn(true)
        spyOn(this.view.smallFrameView, "goToPost")
        this.view.$(".permalink").click()
        expect(this.view.smallFrameView.goToPost).toHaveBeenCalled()
      })
    })
  })
});