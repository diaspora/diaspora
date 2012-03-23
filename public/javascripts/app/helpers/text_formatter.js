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
      // remove < > around markdown-style urls
      var mdUrlRegex = /<((https?|ftp):[^'">\s]+)>/gi;
      text = text.replace(mdUrlRegex, function(wholematch, m1) {
        return m1;
      });

      // regex shamelessly copied from http://daringfireball.net/2010/07/improved_regex_for_matching_urls
      var urlRegex = /\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/g;
      return text.replace(urlRegex, function(url){
        var newUrl = "["+url+"]("+punycode.toASCII(url)+")"; // console.log( punycode.toASCII(url) );
        return newUrl;
      });
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

