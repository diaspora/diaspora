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
    }
  // makes http[s]/www as mandatory in url. As it should not match " end of sentence.hi ..."
  // supports unicode
  // Fail cases:
  //  goutham.me
  //  httpsssss://sdfd.com
  //  htttttp://sdfd.com
  //  jskldf fkdkd s.sf dkll....sd d
  //  goutham..me
  // Success cases:
  //  http://sdfd.com
  //  https://sdfd.com
  //  https://sdfd.sdfdf.sdf-#@~:sdf.com/sdfsdfsd
  //  https://sdfd.sdfdf.sdf-#@~:sdf.com/sdfsdfsd#!/hello
  //  www.goutham.lkds:3000/sdfdsfdsfdsf
  //  www.bürgerentscheid-krankenhäuser.de/this/is/a/ünicode/ürl
    function urlify(text) {
      var urlRegex = /(=\s?'|=\s?")?(http[s]?:\/\/|www){1}\.?(([-@:%_+\.~#?&//=\w]|[^\u0000-\u0080]){2,255}[a-zA-Z0-9])\.[a-z]{2,4}\b(:[0-9]+)?(\/[-a-zA-Z0-9@:%_\+.~#?(#!)&//=;]*|[^\u0000-\u0080]?)*/gi
      return text.replace(urlRegex, function(url, preceeder, bang) {
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

