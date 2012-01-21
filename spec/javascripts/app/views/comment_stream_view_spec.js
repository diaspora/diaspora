describe("app.views.CommentStream", function(){
  beforeEach(function(){
    this.view = new app.views.CommentStream({model : factory.post()})
  })

  describe("postRenderTemplate", function(){
    it("applies infield labels", function(){
      spyOn($.fn, "inFieldLabels")
      this.view.postRenderTemplate()
      expect($.fn.inFieldLabels).toHaveBeenCalled()
      expect($.fn.inFieldLabels.mostRecentCall.object.selector).toBe("label")
    })

    it("autoResizes the new comment textarea", function(){
      spyOn($.fn, "autoResize")
      this.view.postRenderTemplate()
      expect($.fn.autoResize).toHaveBeenCalled()
      expect($.fn.autoResize.mostRecentCall.object.selector).toBe("textarea")
    })
  })
})
