/**
 * Created by .
 * User: dan
 * Date: Jan 25, 2011
 * Time: 5:18:32 PM
 * To change this template use File | Settings | File Templates.
 */
Diaspora.widgets.add("i18n", function() {
  this.start = $.noop;

  this.callbacks = [];
  this.language = undefined;
  this.locale = undefined;
  this.ready = false;

  this.loadLocale = function(locale, language) {
    this.ready = true;
    this.language = language;

    if(typeof locale !== "undefined") {
      this.locale = locale;
      this.triggerCallbacks();
      return;
    }

    if(!this.locale) {
      function setLocale(data) {
        this.locale = $.parseJSON(data);
        this.triggerCallbacks();
      }

      $.getJSON("/localize", setLocale);
    }
  };

  this.triggerCallbacks = function() {
    for(var i = 0; i < this.callbacks.length; i++) {
      this.callbacks[i]();
    }
  };
    
  this.onLocaleLoaded = function(callback) {
    if(this.ready) {
      callback();
      return;
    }
    
    this.callbacks.push(callback);
  };

  this.t = function(item, views) {
    var ret,
      _item = item.split(".");
    
    while(part = _item.shift()) {
      ret = (ret) ? ret[part] : this.locale[part];
    }

    return $.mustache(ret, views || {});
  };
});