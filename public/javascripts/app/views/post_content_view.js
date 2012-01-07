(function(){
  var postContentView = app.views.StreamObject.extend({
    presenter : function(){
      return _.extend(this.defaultPresenter(), {
        text : metafyText(this.model.get("text"))
      })

      function metafyText(text) {
        //we want it to return at least a <p> from markdown
        text = text || ""
        return hashtagify(markdown.toHTML(text) || text)
      }

      function hashtagify(text){
        return text.replace(/(#([\u0080-\uFFFF|\w|-]+|&lt;3))/g, function(tagText) {
          return "<a href='/tags/" + tagText.substring(1) + "' class='tag'>" + tagText + "</a>"
        })
      }
    }
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



