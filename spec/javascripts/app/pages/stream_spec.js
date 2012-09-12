describe("app.Pages.Stream", function(){
  beforeEach(function(){
    app.setPreload("stream", [factory.post().attributes])
    this.page = new app.pages.Stream()
    this.post = this.page.model.items.models[0]
    expect(this.post).toBeTruthy()
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.page.render()
    })

    context("clicking the content", function(){
      it("triggers frame interacted", function(){
        spyOn(this.post.interactions, "fetch").andReturn(new $.Deferred)
        this.page.$('.canvas-frame:first .content').click()
        expect(this.post.interactions.fetch).toHaveBeenCalled()
      })
    })
  })

  context("when more posts are loaded", function(){
    it("navigates to the last post in the stream's max_time", function(){
      spyOn(app.router, 'navigate')
      var url = location.pathname + "?max_time=" + this.post.createdAt()
        , options =  {replace: true}

      this.page.streamView.trigger('loadMore')
      expect(app.router.navigate).toHaveBeenCalledWith(url, options)
    })
  })
});
