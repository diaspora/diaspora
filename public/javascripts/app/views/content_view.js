app.views.Content = app.views.StreamObject.extend({
  presenter : function(){
    var model = this.model
    return _.extend(this.defaultPresenter(), {
      text : app.helpers.textFormatter(model),
      o_embed_html : embedHTML(model)
    })

    function embedHTML(model){
      if(!model.get("o_embed_cache")) { return ""; }
      return model.get("o_embed_cache").data.html
    }
  }
})

app.views.StatusMessage = app.views.Content.extend({
  legacyTemplate : true,
  template_name : "#status-message-template"
});

app.views.Reshare = app.views.Content.extend({
  legacyTemplate : true,
  template_name : "#reshare-template"
});

app.views.ActivityStreams__Photo = app.views.Content.extend({
  legacyTemplate : false,
  templateName : "activity-streams-photo"
});

