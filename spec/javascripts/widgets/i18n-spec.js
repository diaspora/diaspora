/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Diaspora", function() {
  describe("widgets", function() {
    describe("i18n", function() {
      var locale = {
        namespace: {
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

      describe("loadLocale", function() {
        it("sets the class's locale variable", function() {
          Diaspora.I18n.loadLocale(locale);

          expect(Diaspora.I18n.locale).toEqual(locale);
        });
      });

      describe("t", function() {
        var translation;
        beforeEach(function() { Diaspora.I18n.loadLocale(locale); });

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

        describe("count", function() {
          function translateWith(count) {
            translation = Diaspora.I18n.t("namespace.otherNamespace.otherMessage", {
              count: count
            })
          }

          it("returns the 'zero' namespace if the count is zero", function() {
            translateWith(0);

            expect(translation).toEqual("none");
          });

          it("returns the 'one' namespace if the count is one", function() {
            translateWith(1);

            expect(translation).toEqual("just one");
          });

          it("returns the 'few' namespace if the count is 2 or 3", function() {
            translateWith(2);

            expect(translation).toEqual("just a few");

            translateWith(3);

            expect(translation).toEqual("just a few");
          });

          it("returns the 'many' namespace for any number greater than 3", function() {
            translateWith(50);

            expect(translation).toEqual("way too many");
          });
        });
      });
    });
  });
});
