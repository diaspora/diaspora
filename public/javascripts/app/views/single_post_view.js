app.views.SinglePost = app.views.Post.extend({

  className : "loaded",
  next_arrow: $('#forward'),
  previous_arrow: $('#back'),

  postRenderTemplate : function() {
    $('#forward').attr('href', this.model.get('next_post'));
    $('#back').attr('href', this.model.get('previous_post'));
  }
});
