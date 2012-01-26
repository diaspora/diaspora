app.views.Content = app.views.StreamObject.extend({
  presenter : function(){
    var model = this.model
    return _.extend(this.defaultPresenter(), {
      text : app.helpers.textFormatter(model),
      o_embed_html : embedHTML(model)
    })

    function embedHTML(model){
      if(!model.get("o_embed_caches")) { return ""; }
      var html = "";
      $.each(model.get("o_embed_caches"), function() {
        if(this.data.type == "photo") {
          html += '<img src="'+this.data.url;
          html += '" width="'+this.data.width;
          html += '" height="'+this.data.height+'" />';
        } else {
          html += this.data.html || ""
        }
      });
      return html;
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

