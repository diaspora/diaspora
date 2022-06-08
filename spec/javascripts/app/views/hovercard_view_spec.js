describe("app.views.Hovercard", function() {

  afterEach(function() {
    $("body #hovercard_container").remove();
  });

  context("user not signed in", function() {
    beforeEach(function() {
      logout();
      this.view = new app.views.Hovercard();
    });

    describe("_populateHovercard", function() {
      it("doesn't create the aspect dropdown", function() {
        this.view.parent = spec.content();
        this.view._populateHovercard();
        jasmine.Ajax.requests.mostRecent().respondWith({
          status: 200,
          responseText: JSON.stringify({
            id: 1337,
            guid: "ba64fce01b04013aa8db34c93d7886ce",
            name: "Edward Snowden"
          })
        });
        expect(this.view.aspectMembershipDropdown).toEqual(undefined);
      });
    });
  });

  context("user signed in", function() {
    beforeEach(function() {
      loginAs(factory.userAttrs());
      this.view = new app.views.Hovercard();
    });

    describe("initialize", function() {
      it("activates hovercards", function() {
        expect(this.view.active).toBeTruthy();
      });
    });

    describe("mouseIsOverElement", function() {
      it("returns false if the element is undefined", function() {
        expect(this.view.mouseIsOverElement(undefined, $.Event())).toBeFalsy();
      });
    });

    describe("_populateHovercard", function() {
      beforeEach(function() {
        this.view.parent = spec.content();
      });

      it("prevents global error handling for the ajax call", function() {
        spyOn(jQuery, "ajax").and.callThrough();
        this.view._populateHovercard();
        expect(jQuery.ajax).toHaveBeenCalledWith("undefined/hovercard.json", {preventGlobalErrorHandling: true});
      });

      it("creates the aspect dropdown", function() {
        this.view._populateHovercard();
        jasmine.Ajax.requests.mostRecent().respondWith({
          status: 200,
          responseText: JSON.stringify({
            id: 1337,
            guid: "ba64fce01b04013aa8db34c93d7886ce",
            name: "Edward Snowden"
          })
        });
        expect(this.view.aspectMembershipDropdown).not.toEqual(undefined);
      });

      it("renders tags properly", function() {
        this.view._populateHovercard();
        jasmine.Ajax.requests.mostRecent().respondWith({
          status: 200,
          responseText: JSON.stringify({
            id: 1337,
            guid: "ba64fce01b04013aa8db34c93d7886ce",
            name: "Edward Snowden",
            profile: {
              tags: ["first", "second"]
            }
          })
        });

        var first = this.view.hashtags.find("a:contains('#first')");
        var second = this.view.hashtags.find("a:contains('#second')");
        expect(first.length).toEqual(1);
        expect(second.length).toEqual(1);
        expect(first.first()[0].href).toContain(Routes.tag("first"));
        expect(second.first()[0].href).toContain(Routes.tag("second"));
      });

      it("indicates when the user is sharing with me", function() {
        this.view._populateHovercard();
        jasmine.Ajax.requests.mostRecent().respondWith({
          status: 200,
          responseText: JSON.stringify({
            id: 1337,
            guid: "ba64fce01b04013aa8db34c93d7886ce",
            name: "Edward Snowden",
            relationship: "sharing"
          })
        });
        var message = this.view.$el.find("#sharing_message");
        expect(message).toHaveClass("entypo-check");
      });

      it("indicates when the user is not sharing with me", function() {
        this.view._populateHovercard();
        jasmine.Ajax.requests.mostRecent().respondWith({
          status: 200,
          responseText: JSON.stringify({
            id: 1337,
            guid: "ba64fce01b04013aa8db34c93d7886ce",
            name: "Edward Snowden",
            relationship: "receiving"
          })
        });
        var message = this.view.$el.find("#sharing_message");
        expect(message).toHaveClass("entypo-record");
      });
    });
  });
});
