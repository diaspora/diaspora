// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

(function(){
  app.helpers.allowedEmbedsMime = function(mimetype) {
    var v = document.createElement(mimetype[1]);
    return v.canPlayType && v.canPlayType(mimetype[0]) !== "";
  };

  app.helpers.textFormatter = function(text, mentions) {
    mentions = mentions ? mentions : [];

    var md = window.markdownit({
      breaks:      true,
      html:        true,
      linkify:     true,
      typographer: true
    });

    var inlinePlugin = window.markdownitForInline;
    md.use(inlinePlugin, "utf8_symbols", "text", function (tokens, idx) {
      tokens[idx].content = tokens[idx].content.replace(/<->/g, "↔")
                                               .replace(/<-/g,  "←")
                                               .replace(/->/g,  "→")
                                               .replace(/<3/g,  "♥");
    });

    md.use(inlinePlugin, "link_new_window_and_missing_http", "link_open", function (tokens, idx) {
      tokens[idx].attrs.forEach(function(attribute, index, array) {
        if( attribute[0] === "href" ) {
          array[index][1] = attribute[1].replace(/^www\./, "http://www.");
        }
      });
      tokens[idx].attrPush(["target", "_blank"]);
      tokens[idx].attrPush(["rel", "noopener noreferrer"]);
    });

    md.use(inlinePlugin, "responsive_images", "image", function (tokens, idx) {
      tokens[idx].attrPush(["class", "img-responsive"]);
    });

    var hashtagPlugin = window.markdownitHashtag;
    md.use(hashtagPlugin, {
      // compare tag_text_regexp in app/models/acts_as_taggable_on-tag.rb
      hashtagRegExp: "[" + PosixBracketExpressions.word +
                           "\\u055b" + // Armenian emphasis mark
                           "\\u055c" + // Armenian exclamation mark
                           "\\u055e" + // Armenian question mark
                           "\\u058a" + // Armenian hyphen
                           "_" +
                           "\\-" +
                     "]+|<3",
      // compare tag_strings in lib/diaspora/taggable.rb
      preceding: "^|\\s"
    });

    var mentionPlugin = window.markdownitDiasporaMention;
    md.use(mentionPlugin, {
      mentions: mentions,
      allowHovercards: true,
      currentUserId: app.currentUser.get("guid")
    });

    var subPlugin = window.markdownitSub;
    md.use(subPlugin);
    var supPlugin = window.markdownitSup;
    md.use(supPlugin);
    var sanitizerPlugin = window.markdownitSanitizer;
    md.use(sanitizerPlugin, {imageClass: "img-responsive"});

    var hljs = window.hljs;
    md.set({
      highlight: function(str, lang) {
        if (lang && hljs.getLanguage(lang)) {
          try {
            return hljs.highlight(lang, str).value;
          } catch (__) {}
        }

        return "";
      }
    });

    // xmpp: should behave like mailto:
    md.linkify.add("xmpp:","mailto:");
    // mumble:// should behave like http://:
    md.linkify.add("mumble:","http:");
    md.linkify.set({ fuzzyLink: false });

    // Bootstrap table markup
    md.renderer.rules.table_open = function () { return "<table class=\"table table-striped\">\n"; };

    var html5medialPlugin = window.markdownitHTML5Embed;
    md.use(html5medialPlugin, {html5embed: {
      inline: false,
      autoAppend: true,
      renderFn: function handleBarsRenderFn(parsed, mediaAttributes) {
        var attributes = mediaAttributes[parsed.mediaType];
        return HandlebarsTemplates["media-embed_tpl"]({
          mediaType: parsed.mediaType,
          attributes: attributes,
          mimetype: parsed.mimeType,
          sourceURL: parsed.url,
          title: parsed.title,
          fallback: parsed.fallback,
          needsCover: parsed.mediaType === "video"
        });
      },
      attributes: {
        "audio": "controls preload=none",
        "video": "preload=none"
      },
      isAllowedMimeType: app.helpers.allowedEmbedsMime
    }});

    return md.render(text);
  };
})();
// @license-end

