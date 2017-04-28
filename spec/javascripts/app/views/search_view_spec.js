describe("app.views.Search", function() {
  beforeEach(function() {
    spec.content().html(
      "<form action='/search' id='search_people_form'><input id='q' name='q' type='search'/></form>"
    );
  });

  describe("initialize", function() {
    it("calls app.views.SearchBase.prototype.initialize", function() {
      spyOn(app.views.SearchBase.prototype, "initialize");
      this.view = new app.views.Search({el: "#search_people_form"});
      var call = app.views.SearchBase.prototype.initialize.calls.mostRecent();
      expect(call.args[0].typeaheadInput.is($("#search_people_form #q"))).toBe(true);
      expect(call.args[0].remoteRoute).toEqual({url: "/search"});
    });

    it("binds typeahead:select", function() {
      this.view = new app.views.Search({el: "#search_people_form"});
      expect($._data($("#q")[0], "events")["typeahead:select"].length).toBe(1);
    });
  });

  describe("toggleSearchActive", function() {
    beforeEach(function() {
      this.view = new app.views.Search({ el: "#search_people_form" });
      this.typeaheadInput = this.view.$("#q");
    });

    context("focus", function() {
      it("adds the class 'active' when the user focuses the text field", function() {
        expect(this.typeaheadInput).not.toHaveClass("active");
        this.typeaheadInput.trigger("focusin");
        expect(this.typeaheadInput).toHaveClass("active");
      });
    });

    context("blur", function() {
      beforeEach(function() {
        this.typeaheadInput.addClass("active");
      });

      it("removes the class 'active' when the user blurs the text field", function() {
        this.typeaheadInput.trigger("focusout");
        expect(this.typeaheadInput).not.toHaveClass("active");
      });
    });
  });
});
