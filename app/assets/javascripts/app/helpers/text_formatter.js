(function(){
  //make it so I take text and mentions rather than the modelapp.helpers.textFormatter(
  var textFormatter = function textFormatter(text, model) {
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
      // regex copied from: http://daringfireball.net/2010/07/improved_regex_for_matching_urls (slightly modified)
      var urlRegex = /(^|\s)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/gi;
      text = text.replace(urlRegex, function(wholematch, space, url) {
        return space+"<"+url+">";
      });

      // process links
      // regex copied from: https://code.google.com/p/pagedown/source/browse/Markdown.Converter.js#1198 (and slightly expanded)
      var linkRegex = /(\[.*\]:\s)?(<|\()((https?|ftp):\/\/[^\/'">\s][^'">\s]+)(>|\))/gi;
      text = text.replace(linkRegex, function() {
        var unicodeUrl = arguments[3];
        var addr = parse_url(unicodeUrl);
        var asciiUrl = // rebuild the url
          (!addr.scheme ? '' : addr.scheme +
          ( (addr.scheme.toLowerCase()=="mailto") ? ':' : '://')) +
          (!addr.user ? '' : addr.user +
          (!addr.pass ? '' : ':'+addr.pass) + '@') +
         punycode.toASCII(addr.host) +
          (!addr.port ? '' : ':' + addr.port) +
          (!addr.path ? '' : encodeURI(addr.path) ) +
          (!addr.query ? '' : '?' + encodeURI(addr.query) ) +
          (!addr.fragment ? '' : '#' + encodeURI(addr.fragment) );
        if( !arguments[1] || arguments[1] == "") { // inline link
          if(arguments[2] == "<") return "["+unicodeUrl+"]("+asciiUrl+")"; // without link text
          else return arguments[2]+asciiUrl+arguments[5]; // with link text
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
        return (diasporaId == person.diaspora_id || person.handle) //jquery.mentionsInput gives us person.handle
      })
      if(person) {
        var url = person.url || "/people/" + person.guid //jquery.mentionsInput gives us person.url
          , personText = "<a href='" + url + "' class='mention'>" + fullName + "</a>"
      } else {
        personText = fullName;
      }

      return personText
    })
  }

  app.helpers.textFormatter = textFormatter;
})();

