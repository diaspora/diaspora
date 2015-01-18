// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

(function(){
  app.helpers.textFormatter = function(text, mentions) {
    mentions = mentions ? mentions : [];

    var punycodeURL = function(url){
      try {
        while(url.indexOf("%") !== -1 && url != decodeURI(url)) url = decodeURI(url);
      }
      catch(e){}

      var addr = parse_url(url);
      if( !addr.host ) addr.host = ""; // must not be 'undefined'

      url = // rebuild the url
        (!addr.scheme ? '' : addr.scheme +
        ( (addr.scheme.toLowerCase()=="mailto") ? ':' : '://')) +
        (!addr.user ? '' : addr.user +
        (!addr.pass ? '' : ':'+addr.pass) + '@') +
        punycode.toASCII(addr.host) +
        (!addr.port ? '' : ':' + addr.port) +
        (!addr.path ? '' : encodeURI(addr.path) ) +
        (!addr.query ? '' : '?' + encodeURI(addr.query) ) +
        (!addr.fragment ? '' : '#' + encodeURI(addr.fragment) );
      return url;
    };

    var md = window.markdownit({
      breaks:      true,
      html:        true,
      linkify:     true,
      typographer: true
    });

    var inlinePlugin = window.markdownitForInline;
    md.use(inlinePlugin, 'utf8_symbols', 'text', function (tokens, idx) {
      tokens[idx].content = tokens[idx].content.replace(/<->/g, "↔")
                                               .replace(/<-/g,  "←")
                                               .replace(/->/g,  "→")
                                               .replace(/<3/g,  "♥");
    });

    md.use(inlinePlugin, 'link_new_window_and_punycode', 'link_open', function (tokens, idx) {
      tokens[idx].href = punycodeURL(tokens[idx].href);
      tokens[idx].target = "_blank";
    });

    md.use(inlinePlugin, 'image_punycode', 'image', function (tokens, idx) {
      tokens[idx].src = punycodeURL(tokens[idx].src);
    });

    var hashtagPlugin = window.markdownitHashtag;
    md.use(hashtagPlugin, {
      // compare tag_text_regexp in app/models/acts_as_taggable_on-tag.rb
      hashtagRegExp: '[' + PosixBracketExpressions.alnum + '_\\-]+|<3',
      // compare tag_strings in lib/diaspora/taggabe.rb
      preceding: '^|\\s'
    });

    var mentionPlugin = window.markdownitDiasporaMention;
    var subPlugin = window.markdownitSub;
    var supPlugin = window.markdownitSup;
    var sanitizerPlugin = window.markdownitSanitizer;
    var emojiPlugin = window.markdownitEmoji;

    md.use(mentionPlugin, mentions)
      .use(sanitizerPlugin)
      .use(supPlugin)
      .use(subPlugin)
      .use(emojiPlugin);

    // TODO this is a temporary fix
    // remove it as soon as markdown-it fixes its autolinking feature
    var linkifyPlugin = window.markdownitDiasporaLinkify;
    md.use(linkifyPlugin);

    // Bootstrap table markup
    md.renderer.rules.table_open = function () { return '<table class="table table-striped">\n'; };

    // use twemoji library for emojis
    md.renderer.rules.emoji = function (token, idx) {
      return twemoji.parse (token[idx].to, { base: '/assets/twemoji/' });
    };

    return md.render(text);
  };
})();
// @license-end

