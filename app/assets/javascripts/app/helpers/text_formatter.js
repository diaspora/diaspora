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

    // punycode non-ascii chars in urls
    converter.hooks.chain("preConversion", function(text) {

      // add < > around plain urls, effectively making them "autolinks"
      var urlRegex = /(^|\s)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/gi;
      text = text.replace(urlRegex, function(wholematch, space, url) {
        return space+"<"+url+">";
      });

      // process links
      var linkRegex = /(\[.*\]:\s)?(<|\()(((https?|ftp):\/{1,3})([^'">\s]+))(>|\))/gi;
      text = text.replace(linkRegex, function() {
        var protocol = arguments[4];
        var unicodeUrl = arguments[6];
        var asciiUrl = protocol+punycode.toASCII(unicodeUrl);
        if( !arguments[1] || arguments[1] == "") { // inline link
          if(arguments[2] == "<") return "["+protocol+unicodeUrl+"]("+asciiUrl+")"; // without link text
          else return arguments[2]+asciiUrl+arguments[7]; // with link text
        } else { // reference style link
          return arguments[1]+asciiUrl;
        }
      });

      return text;
    });

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

