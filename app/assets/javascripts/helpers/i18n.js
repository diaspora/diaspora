Diaspora.I18n = {
  language: "en",
  locale: {
    pluralizationKey: function(n) { return this.fallback.pluralizationKey(n); },
    data: {},
    fallback: {
      pluralizationKey: function(n) { return n == 1 ? "one" : "other"; },
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

    rule = this.resolve(locale, ['pluralization_rule']);
    if (rule !== "") {
      eval("locale.pluralizationKey = "+rule);
    }
  },

  t: function(item, views) {
    var items = item.split(".");
    return this.resolve(this.locale, items, views);
  },

  resolve: function(locale, items, views) {
      var translatedMessage, nextNamespace, originalItems = items.slice();

    if(views && typeof views.count !== "undefined") {
      items.push(locale.pluralizationKey(views.count));
    }

    while(nextNamespace = items.shift()) {
      translatedMessage = (translatedMessage)
        ? translatedMessage[nextNamespace]
        : locale.data[nextNamespace];

      if(typeof translatedMessage === "undefined") {
        if (typeof locale.fallback === "undefined") {
          return "";
        } else {
          return this.resolve(locale.fallback, originalItems, views);
        }
      }
    }

    try {
      return _.template(translatedMessage, views || {});
    } catch (e) {
      if (typeof locale.fallback === "undefined") {
        return "";
      } else {
        return this.resolve(locale.fallback, originalItems, views);
      }
    }
  },

  reset: function() {
    this.locale.data = {};

    if( arguments.length > 0 && !(_.isEmpty(arguments[0])) )
      this.locale.data = arguments[0];
  }
};
