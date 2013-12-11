app.views.PostViewerNewComment = app.views.Base.extend({

  templateName: "single-post-viewer/new-comment",

  events : {
    "click button" : "createComment",
    "focus textarea" : "scrollToBottom"
  },

  scrollableArea : "#post-reactions",

  initialize : function(){
    this.model.interactions.comments.bind("sync", this.clearAndReactivateForm, this)
  },

  postRenderTemplate : function() {
    this.$("textarea").placeholder();
    this.$("textarea").autoResize({'extraSpace' : 0});
  },

  createComment: function(evt) {
    if(evt){ evt.preventDefault(); }
    this.toggleFormState()
    this.model.comment(this.$("textarea").val());
  },

  clearAndReactivateForm : function() {
    this.toggleFormState()
    this.$("textarea").val("")
      .css('height', '18px')
      .focus()
  },

  toggleFormState : function() {
    this.$("form").children().toggleClass('disabled')
  },

  scrollToBottom : function() {
    $(this.scrollableArea).scrollTop($(this.scrollableArea).prop("scrollHeight"))
  }

});
