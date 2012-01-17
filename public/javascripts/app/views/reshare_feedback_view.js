app.views.ReshareFeedback = app.views.Feedback.extend({
  initialize : function(){
    this.reshareablePost = (this.model instanceof app.models.Reshare) ? this.model.rootPost() : new app.models.Reshare(this.model.attributes).rootPost();
    this.setupRenderEvents();
  }
});
