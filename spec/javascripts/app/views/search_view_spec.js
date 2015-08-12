describe("app.views.Search", function() {
  beforeEach(function(){
    spec.content().html(
      "<form action='/search' id='search_people_form'><input id='q' name='q' type='search'></input></form>"
    );
  });

  describe("initialize", function() {
    it("calls setupBloodhound", function() {
      spyOn(app.views.Search.prototype, "setupBloodhound").and.callThrough();
      new app.views.Search({ el: "#search_people_form" });
      expect(app.views.Search.prototype.setupBloodhound).toHaveBeenCalled();
    });

    it("calls setupTypeahead", function() {
      spyOn(app.views.Search.prototype, "setupTypeahead");
      new app.views.Search({ el: "#search_people_form" });
      expect(app.views.Search.prototype.setupTypeahead).toHaveBeenCalled();
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

  describe("transformBloodhoundResponse" , function() {
    beforeEach(function() {
      this.view = new app.views.Search({ el: "#search_people_form" });
    });
    context("with persons", function() {
      beforeEach(function() {
        this.response = [{name: "Person", handle: "person@pod.tld"},{name: "User", handle: "user@pod.tld"}];
      });

      it("sets data.person to true", function() {
        expect(this.view.transformBloodhoundResponse(this.response)).toEqual([
         {name: "Person", handle: "person@pod.tld", person: true},
         {name: "User", handle: "user@pod.tld", person: true}
        ]);
      });
    });

    context("with hashtags", function() {
      beforeEach(function() {
        this.response = [{name: "#tag"}, {name: "#hashTag"}];
      });

      it("sets data.hashtag to true and adds the correct URL", function() {
        expect(this.view.transformBloodhoundResponse(this.response)).toEqual([
         {name: "#tag", hashtag: true, url: Routes.tag("tag")},
         {name: "#hashTag", hashtag: true, url: Routes.tag("hashTag")}
        ]);
      });
    });
  });
});
