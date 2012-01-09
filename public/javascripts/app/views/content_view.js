app.views.Content = app.views.StreamObject.extend({
  presenter : function(){
    var model = this.model
    return _.extend(this.defaultPresenter(), {
      text : metafyText(model.get("text"))
    })

    function metafyText(text) {
      //we want it to return at least a <p> from markdown
      text = text || ""
      return urlify(
        mentionify(
          hashtagify(
            markdownify(text)
          )
        )
      )
    }

    function markdownify(text){
      //markdown returns falsy when it performs no substitutions, apparently...
      return markdown.toHTML(text) || text
    }

    function hashtagify(text){
      var utf8WordCharcters =/(\s|^|>)#([\u0080-\uFFFF|\w|-]+|&lt;3)/g
      return text.replace(utf8WordCharcters, function(hashtag, preceeder, tagText) {
        return preceeder + "<a href='/tags/" + tagText + "' class='tag'>#" + tagText + "</a>"
      })
    }

    function mentionify(text) {
      var mentionRegex = /@\{([^;]+); ([^\}]+)\}/g
      return text.replace(mentionRegex, function(mentionText, fullName, diasporaId) {
        var personId = _.find(model.get("mentioned_people"), function(person){
          return person.diaspora_id == diasporaId
        }).id

        return "<a href='/people/" + personId + "' class='mention'>" + fullName + "</a>"
      })
      return text
    }

    function urlify(text) {
      var urlRegex = /(=\s?'|=\s?")?[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/gi
      return text.replace(urlRegex, function(url, preceeder) {
        if(preceeder) return url
        var protocol = (url.search(/:\/\//) == -1 ? "http://" : "")
        return "<a href='" + protocol + url + "' target=_blank>" + url + "</a>"
      })
    }
  }
})


app.views.StatusMessage = app.views.Content.extend({
  template_name : "#status-message-template"
});

app.views.Reshare = app.views.Content.extend({
  template_name : "#reshare-template"
});

app.views.ActivityStreams__Photo = app.views.Content.extend({
  template_name : "#activity-streams-photo-template"
});

