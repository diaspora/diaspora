/**
 * Created by .
 * User: dan
 * Date: Jan 27, 2011
 * Time: 3:20:57 PM
 * To change this template use File | Settings | File Templates.
 */
describe("Diaspora", function() {
  describe("widgets", function() {
    describe("i18n", function() {
      describe("loadLocale", function() {
        it("sets the class's locale variable", function() {
          Diaspora.widgets.i18n.loadLocale({sup: "hi"});
          expect(Diaspora.widgets.i18n.locale).toEqual({sup: "hi"});
        });
      });
      describe("t", function() {
        it("returns the specified translation", function() {
          Diaspora.widgets.i18n.loadLocale({yo: "sup"}, "en");
          var translation = Diaspora.widgets.i18n.t("yo");
          expect(translation).toEqual("sup");
        });
        it("will go through a infinitely deep object", function() {
          Diaspora.widgets.i18n.loadLocale({
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
         expect(Diaspora.widgets.i18n.t("yo.hi.sup.test")).toEqual("test");
         expect(Diaspora.widgets.i18n.t("more.another")).toEqual("i hope this spec is green");
        });
        it("can render a mustache template", function() {
          Diaspora.widgets.i18n.loadLocale({yo: "{{yo}}"}, "en");
          expect(Diaspora.widgets.i18n.t("yo", {yo: "it works!"})).toEqual("it works!");
        });
        it("returns an empty string if the translation is not found", function() {
          expect(Diaspora.widgets.i18n.t("thisstringdoesnotexist")).toEqual("");
        });
      });
    });
  });
});