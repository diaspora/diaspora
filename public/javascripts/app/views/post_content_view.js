(function(){
  var postContentView = app.views.StreamObject.extend({
    presenter : function(){
      return _.extend(this.defaultPresenter(), {
        text : markdown.toHTML(this.model.get("text") || "")
      })
    },
  })


  app.views.StatusMessage = postContentView.extend({
    template_name : "#status-message-template"
  });

  app.views.Reshare = postContentView.extend({
    template_name : "#reshare-template"
  });

  app.views.ActivityStreams__Photo = postContentView.extend({
    template_name : "#activity-streams-photo-template"
  });
})();



