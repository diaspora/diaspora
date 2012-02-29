app.views.PostViewerNewComment = app.views.Base.extend({

  templateName: "post-viewer/new-comment",

  events : {
    "click button" : "createComment",
    "focus textarea" : "scrollToBottom"
  },

  scrollableArea : "#post-reactions",

  postRenderTemplate : function() {
    this.$("textarea").placeholder();
    this.$("textarea").autoResize({'extraSpace' : 0});
  },

  createComment: function(evt) {
    if(evt){ evt.preventDefault(); }

    var self = this;

    this.toggleFormState()
    this.model.comments.create({
      "text" : this.$("textarea").val()
    }, {success : _.bind(self.clearAndReactivateForm, self)});

  },

  clearAndReactivateForm : function() {
    this.model.trigger("interacted")
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

})
