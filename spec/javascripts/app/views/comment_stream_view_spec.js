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
  
  describe("createComment", function() {
    beforeEach(function() {
      jasmine.Ajax.useMock();
      this.view.render();
      this.view.expandComments();
    })
    
    it("submits the new comment when comment text is not empty", function() {
      this.view.$(".comment_box").val('a new comment');
      this.view.createComment();
      expect(this.view.$(".comment-content p").text()).toEqual("a new comment");
    })
    
    it("clears the comment box when there are only spaces", function() {
      this.view.$(".comment_box").val('   ');
      this.view.createComment();
      expect(this.view.$(".comment_box").val()).toEqual("");
    })
    
    it("resets comment box height", function() {
      this.view.$(".comment_box").val('a new comment');
      this.view.createComment();
      expect(this.view.$(".comment_box").attr("style")).not.toContain("height");
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

  describe("expandComments", function() {
    it("refills the comment textbox on success", function() {
      jasmine.Ajax.useMock();

      this.view.render();

      this.view.$("textarea").val("great post!");

      this.view.expandComments();

      mostRecentAjaxRequest().response({ comments : [] });

      expect(this.view.$("textarea").val()).toEqual("great post!");
    })
  })
})
