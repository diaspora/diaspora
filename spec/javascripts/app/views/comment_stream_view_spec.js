describe("app.views.CommentStream", function(){
  beforeEach(function(){
    this.view = new app.views.CommentStream({model : factory.post()})
    loginAs({})
  })

  describe("binds", function() {
    it("re-renders on a commentsExpanded trigger", function(){
      spyOn(this.view, "render");
      this.view.setupBindings();
      this.view.model.trigger("commentsExpanded");
      expect(this.view.render).toHaveBeenCalled();
    })
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
    beforeEach(function(){
      spyOn(this.view.model.comments, "create")
    })

    it("clears the new comment textarea", function(){
      var comment = {
        "id": 1234,
        "text": "hey",
        "author": "not_null"
      };
      spyOn($, "ajax").andCallFake(function(params) {
        params.success(comment);
      });

      $(this.view.el).html($("<textarea/>", {"class" : 'comment_box'}).val(comment.text))
      this.view.createComment()
      expect(this.view.$(".comment_box").val()).toBe("")
      expect(this.view.model.comments.create).toHaveBeenCalled()
    })
  })

  describe("appendComment", function(){
    it("appends this.model as 'parent' to the comment", function(){
      var comment = new app.models.Comment(factory.comment())

      spyOn(comment, "set")
      this.view.appendComment(comment)
      expect(comment.set).toHaveBeenCalled()
    })
  })
})
