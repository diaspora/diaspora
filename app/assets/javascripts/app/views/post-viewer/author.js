app.views.PostViewerAuthor = app.views.Base.extend({

  id : "post-author",
  className : "media",

  tooltipSelector : ".profile-image-container",

  templateName: "post-viewer/author",

  initialize : function() {
    /* add a class so we know how to color the text for the author name */
    this.$el.addClass(this.model.get("frame_name"))
  }

});