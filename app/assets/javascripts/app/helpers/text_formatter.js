
// cache url regex globally, for direct acces when testing
$(function() {
  Diaspora.url_regex = /(^|\s)\b((?:(?:https?|ftp):(?:\/{1,3})|www\.)(?:[^"<>\)\s]|\(([^\s()<>]+|(\([^\s()<>]+\)))\))+)(?=\s|$)/gi;
});

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
      text = text.replace(Diaspora.url_regex, function() {
        var url = arguments[2];
        if( url.match(/^[^\w]/) ) return url; // evil witchcraft, noop
        return arguments[1]+"<"+url+">";
      });

      // process links
      // regex copied from: https://code.google.com/p/pagedown/source/browse/Markdown.Converter.js#1198 (and slightly expanded)
      var linkRegex = /(\[.*\]:\s)?(<|\()((?:(https?|ftp):\/\/[^\/'">\s]|www)[^'">\s]+?)([>\)]{1,2})/gi;
      text = text.replace(linkRegex, function() {
        var unicodeUrl = arguments[3];
        var urlSuffix = arguments[5];

        unicodeUrl = ( unicodeUrl.match(/^www/) ) ? ('http://' + unicodeUrl) : unicodeUrl;

        // handle parentheses, especially in case the link ends with ')'
        if( urlSuffix.indexOf(')') != -1 && urlSuffix.indexOf('>') != -1 ) {
          unicodeUrl += ')';
          urlSuffix = '>';
        }
        // markdown doesn't like '(' or ')' anywhere, except where it wants
        var workingUrl = unicodeUrl.replace(/\(/, "%28").replace(/\)/, "%29");

        var addr = parse_url(unicodeUrl);
        if( !addr.host ) addr.host = ""; // must not be 'undefined'

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
          if(arguments[2] == "<") return "["+workingUrl+"]("+asciiUrl+")"; // without link text
          else return arguments[2]+asciiUrl+urlSuffix; // with link text
        } else { // reference style link
          return arguments[1]+asciiUrl;
        }
      });

      return text;
    });

    // make nice little utf-8 symbols
    converter.hooks.chain("preConversion", function(text) {
      var input_strings = [
        "<->", "->", "<-",
        "(c)", "(r)", "(tm)",
        "<3"
      ];
      var output_symbols = [
        "↔", "→", "←",
        "©", "®", "™",
        "♥"
      ];
      // quote function from: http://stackoverflow.com/a/494122
      var quote = function(str) {
        return str.replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1");
      };

      _.each(input_strings, function(str, idx) {
        var r = new RegExp(quote(str), "gi");
        text = text.replace(r, output_symbols[idx]);
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
      return preceeder + "<a href='/tags/" + tagText.toLowerCase() +
                         "' class='tag'>#" + tagText + "</a>"
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

