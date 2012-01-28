describe("app.views.CommentStream", function(){
  beforeEach(function(){
    this.view = new app.views.CommentStream({model : factory.post()})
  })

  describe("postRenderTemplate", function(){
    it("applies infield labels", function(){
      spyOn($.fn, "placeholder")
      this.view.postRenderTemplate()
      expect($.fn.placeholder).toHaveBeenCalled()
      expect($.fn.placeholder.mostRecentCall.object.selector).toBe("textarea")
    })

    it("autoResizes the new comment textarea", function(){
      spyOn($.fn, "autoResize")
      this.view.postRenderTemplate()
      expect($.fn.autoResize).toHaveBeenCalled()
      expect($.fn.autoResize.mostRecentCall.object.selector).toBe("textarea")
    })
  })

  describe("createComment", function(){
    it("clears the new comment textarea", function(){
      $(this.view.el).html($("<textarea/>", {"class" : 'comment_box'}).val("hey"))
      this.view.createComment()
      expect(this.view.$(".comment_box").val()).toBe("")
    })
  })
})
