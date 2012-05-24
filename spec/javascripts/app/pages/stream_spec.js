describe("app.Pages.Stream", function(){
  beforeEach(function(){
    app.setPreload("stream", [factory.post().attributes])
    this.page = new app.pages.Stream()
    this.post = this.page.model.items.models[0]
    expect(this.post).toBeTruthy()
  })


  describe('postRenderTemplate', function(){
    it("sets the background-image of #header", function(){
      this.page.render()
      expect(this.page.$('#header').css('background-image')).toBeTruthy()
    })

    it('calls setUpHashChangeOnStreamLoad', function(){
      spyOn(this.page, 'setUpHashChangeOnStreamLoad')
      this.page.render();
      expect(this.page.setUpHashChangeOnStreamLoad).toHaveBeenCalled()
    })
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

  describe("setUpHashChangeOnStreamLoad", function(){
    it('calls navigateToPost on the loadMore event', function(){
      spyOn(this.page, 'navigateToPost')
      this.page.setUpHashChangeOnStreamLoad()
      this.page.streamView.trigger('loadMore')
      expect(this.page.navigateToPost).toHaveBeenCalled()
    })
  })

  describe("navigateToPost", function(){
    it("sets the max time of the url to the created at time of a post", function(){
      spyOn(app.router, 'navigate')
      this.page.navigateToPost(this.post)
      var url = location.pathname + "?ex=true&max_time=" + this.post.createdAt()
      var options =  {replace: true}
      expect(app.router.navigate).toHaveBeenCalledWith(url, options)
    })
  })
});