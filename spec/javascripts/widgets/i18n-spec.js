/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Diaspora.I18n", function() {
  var locale = {namespace: {
      message: "hey",
      template: "<%= myVar %>",
      otherNamespace: {
        message: "hello from another namespace",
        otherMessage: {
          zero: "none",
          one: "just one",
          few: "just a few",
          many: "way too many",
          other: "what?"
        }
      }
    }
  };

  beforeEach(function(){
    Diaspora.I18n.reset();   // run tests with clean locale
  });

  describe("::load", function() {
    it("sets the class's locale variable", function() {
      Diaspora.I18n.load(locale, "en", locale);

      expect(Diaspora.I18n.locale.data).toEqual(locale);
      expect(Diaspora.I18n.locale.fallback.data).toEqual(locale);
    });

    it("extends the class's locale variable on multiple calls", function() {
      var data = {another: 'section'},
          extended = $.extend(locale, data);

      Diaspora.I18n.load(locale, "en", locale);
      Diaspora.I18n.load(data, "en", data);

      expect(Diaspora.I18n.locale.data).toEqual(extended);
    });
  });

  describe("::t", function() {
    var translation;
    beforeEach(function() { Diaspora.I18n.load(locale, "en", {fallback: "fallback", namespace: {template: "no template"}}); });

    it("returns the specified translation", function() {
      translation = Diaspora.I18n.t("namespace.message");

      expect(translation).toEqual("hey");
    });

    it("will go through a infinitely deep object", function() {
      translation = Diaspora.I18n.t("namespace.otherNamespace.message");

      expect(translation).toEqual("hello from another namespace");
    });

    it("can render a mustache template", function() {
      translation = Diaspora.I18n.t("namespace.template", { myVar: "it works!" });

      expect(translation).toEqual("it works!");
    });

    it("returns an empty string if the translation is not found", function() {
      expect(Diaspora.I18n.t("missing.locale")).toEqual("");
    });

    it("falls back on missing key", function() {
      expect(Diaspora.I18n.t("fallback")).toEqual("fallback");
    });

    it("falls back on interpolation errors", function() {
      expect(Diaspora.I18n.t("namespace.template")).toEqual("no template");
    });
  });

  describe("::resolve", function() {
    it("allows to retrieve entire sections", function() {
      Diaspora.I18n.load(locale, "en", {});
      expect(Diaspora.I18n.resolve("namespace")).toEqual(locale["namespace"]);
    });
  });

  describe("::reset", function(){
    it("clears the current locale", function() {
      Diaspora.I18n.load(locale, "en", locale);
      Diaspora.I18n.reset()
      expect(Diaspora.I18n.locale.data).toEqual({});
    });

    it("sets the locale to only a specific value", function() {
      var data = { some: 'value' };
      Diaspora.I18n.load(locale, "en", locale);
      Diaspora.I18n.reset(data);
      expect(Diaspora.I18n.locale.data).toEqual(data);
    });
  });
});
