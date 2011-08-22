/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Diaspora", function() {
  describe("widgets", function() {
    describe("i18n", function() {
      describe("loadLocale", function() {
        it("sets the class's locale variable", function() {
          Diaspora.I18n.loadLocale({sup: "hi"});
          expect(Diaspora.I18n.locale).toEqual({sup: "hi"});
        });
      });
      describe("t", function() {
        it("returns the specified translation", function() {
          Diaspora.I18n.loadLocale({yo: "sup"}, "en");
          var translation = Diaspora.I18n.t("yo");
          expect(translation).toEqual("sup");
        });
        it("will go through a infinitely deep object", function() {
          Diaspora.I18n.loadLocale({
            yo: {
              hi: {
                sup: {
                  test: "test"
                }
              }
            },
            more: {
              another: "i hope this spec is green"
            }
          });
         expect(Diaspora.I18n.t("yo.hi.sup.test")).toEqual("test");
         expect(Diaspora.I18n.t("more.another")).toEqual("i hope this spec is green");
        });
        it("can render a mustache template", function() {
          Diaspora.I18n.loadLocale({yo: "{{yo}}"}, "en");
          expect(Diaspora.I18n.t("yo", {yo: "it works!"})).toEqual("it works!");
        });
        it("returns an empty string if the translation is not found", function() {
          expect(Diaspora.I18n.t("thisstringdoesnotexist")).toEqual("");
        });
      });
    });
  });
});