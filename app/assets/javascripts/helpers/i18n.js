// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.I18n = {
  language: "en",
  locale: {
    pluralizationKey: function(n) { return this.fallback.pluralizationKey(n); },
    data: {},
    fallback: {
      pluralizationKey: function(n) { return n === 1 ? "one" : "other"; },
      data: {}
    }
  },

  load: function(locale, language, fallbackLocale) {
    this.updateLocale(this.locale, locale);
    this.updateLocale(this.locale.fallback, fallbackLocale);
    this.language = language;
  },

  updateLocale: function(locale, data) {
    locale.data = $.extend(locale.data, data);

    var rule = this._resolve(locale, ['pluralization_rule']);
    if (rule !== "") {
      /* jshint evil:true */
      // TODO change this to `locale.pluralizationKey = rule`?
      eval("locale.pluralizationKey = "+rule);
      /* jshint evil:false */
    }
  },

  t: function(item, views) {
    return this._render(this.locale, item.split("."), views);
  },

  resolve: function(item) {
    return this._resolve(this.locale, item.split("."));
  },

  _resolve: function(locale, items) {
    var translatedMessage, nextNamespace, originalItems = items.slice();

    while( (nextNamespace = items.shift()) ) {
      translatedMessage = (translatedMessage)
        ? translatedMessage[nextNamespace]
        : locale.data[nextNamespace];

      if(typeof translatedMessage === "undefined") {
        if (typeof locale.fallback === "undefined") {
          return "";
        } else {
          return this._resolve(locale.fallback, originalItems);
        }
      }
    }

    return translatedMessage;
  },

  _render: function(locale, items, views) {
    var originalItems = items.slice();

    if(views && typeof views.count !== "undefined") {
      items.push(locale.pluralizationKey(views.count));
    }

    try {
      return _.template(this._resolve(locale, items))(views || {});
    } catch (e) {
      if (typeof locale.fallback === "undefined") {
        return "";
      } else {
        return this._render(locale.fallback, originalItems, views);
      }
    }
  },

  reset: function() {
    this.locale.data = {};

    if( arguments.length > 0 && !(_.isEmpty(arguments[0])) )
      this.locale.data = arguments[0];
  }
};
// @license-end

