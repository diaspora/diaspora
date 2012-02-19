(function(){
  var textFormatter = function textFormatter(model) {
    var text = model.get("text");
    var mentions = model.get("mentioned_people");

    return textFormatter.mentionify(
      textFormatter.hashtagify(
        textFormatter.markdownify(text)
        ), mentions
      )
  };

  textFormatter.markdownify = function markdownify(text){
    var converter = Markdown.getSanitizingConverter();
    
    converter.hooks.chain("postConversion", function (text) {
      return text.replace(/(\"(?:(?:http|https):\/\/)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(?:\/\S*)?\")(\>)/g, '$1 target="_blank">')
    });

    return converter.makeHtml(text)
  };

  textFormatter.hashtagify = function hashtagify(text){
    var utf8WordCharcters =/(\s|^|>)#([\u0080-\uFFFF|\w|-]+|&lt;3)/g
    return text.replace(utf8WordCharcters, function(hashtag, preceeder, tagText) {
      return preceeder + "<a href='/tags/" + tagText + "' class='tag'>#" + tagText + "</a>"
    })
  };

  textFormatter.mentionify = function mentionify(text, mentions) {
    var mentionRegex = /@\{([^;]+); ([^\}]+)\}/g
    return text.replace(mentionRegex, function(mentionText, fullName, diasporaId) {
      var person = _.find(mentions, function(person){
        return person.diaspora_id == diasporaId
      })
      
      return person ? "<a href='/people/" + person.guid + "' class='mention'>" + fullName + "</a>" : fullName;
    })
  }

  app.helpers.textFormatter = textFormatter;
})();

