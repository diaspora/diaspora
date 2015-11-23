describe("app.views.Search", function(){
  beforeEach(function(){
    spec.content().html(
      "<form action='/search' id='search_people_form'><input id='q' name='q' type='search'/></form>"
    );
  });

  describe("initialize", function(){
    it("calls completeSetup", function(){
      spyOn(app.views.Search.prototype, "completeSetup").and.callThrough();
      var view = new app.views.Search({el: "#search_people_form"});
      expect(app.views.Search.prototype.completeSetup).toHaveBeenCalledWith(view.getTypeaheadElement());
    });

    it("calls bindMoreSelectionEvents", function(){
      spyOn(app.views.Search.prototype, "bindMoreSelectionEvents").and.callThrough();
      new app.views.Search({el: "#search_people_form"});
      expect(app.views.Search.prototype.bindMoreSelectionEvents).toHaveBeenCalled();
    });
  });

  describe("bindMoreSelectionEvents", function(){
    beforeEach(function() {
      this.view = new app.views.Search({ el: "#search_people_form" });
      this.view.bloodhound.add([
        {"person": true, "name":"user1", "handle":"user1@pod.tld"},
        {"person": true, "name":"user2", "handle":"user2@pod.tld"}
      ]);
    });

    context("bind mouseleave event", function(){
      it("binds mouseleave event only once", function(){
        this.view.$("#q").trigger("focusin");
        this.view.$("#q").val("user");
        this.view.$("#q").trigger("keypress");
        this.view.$("#q").trigger("input");
        this.view.$("#q").trigger("focus");
        var numBindedEvents = $._data(this.view.$(".tt-menu")[0], "events").mouseout.length;
        expect(numBindedEvents).toBe(1);
        this.view.$("#q").trigger("focusout");
        this.view.$("#q").trigger("focusin");
        this.view.$("#q").val("user");
        this.view.$("#q").trigger("keypress");
        this.view.$("#q").trigger("input");
        this.view.$("#q").trigger("focus");
        numBindedEvents = $._data(this.view.$(".tt-menu")[0], "events").mouseout.length;
        expect(numBindedEvents).toBe(1);
      });

      it("remove result highlight when leaving results list", function(){
        this.view.$("#q").trigger("focusin");
        this.view.$("#q").val("user");
        this.view.$("#q").trigger("keypress");
        this.view.$("#q").trigger("input");
        this.view.$("#q").trigger("focus");
        this.view.$(".tt-menu .tt-suggestion").first().trigger("mouseover");
        expect(this.view.$(".tt-menu .tt-suggestion").first()).toHaveClass("tt-cursor");
        this.view.$(".tt-menu").first().trigger("mouseleave");
        expect(this.view.$(".tt-menu .tt-cursor").length).toBe(0);
      });
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
