app.models.Reshare = app.models.Post.extend({
  url : function() { return "/reshares"; }
});
