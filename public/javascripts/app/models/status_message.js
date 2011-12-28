app.models.StatusMessage = app.models.Post.extend({
  url : function() { return "/status_messages"; }
});
