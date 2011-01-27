/**
 * Created by .
 * User: dan
 * Date: Jan 25, 2011
 * Time: 5:18:32 PM
 * To change this template use File | Settings | File Templates.
 */
Diaspora.widgets.add("i18n", function() {
  this.start = $.noop;

  this.language = undefined;
  this.locale = undefined;

  this.loadLocale = function(locale, language) {
    this.language = language;
    this.locale = locale;
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