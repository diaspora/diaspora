describe("app.views.SearchBase", function() {
  beforeEach(function() {
    spec.content().html(
      "<form action='/search' id='search_people_form'><input id='q' name='q' type='search'/></form>"
    );
    this.search = function(view, name) {
      view.$("#q").trigger("focusin");
      view.$("#q").val(name);
      view.$("#q").trigger("keypress");
      view.$("#q").trigger("input");
      view.$("#q").trigger("focus");
    };
    this.bloodhoundData = [
      {"person": true, "name": "user1", "handle": "user1@pod.tld", url: "/people/1"},
      {"person": true, "name": "user2", "handle": "user2@pod.tld", url: "/people/2"}
    ];
  });

  describe("initialize", function() {
    it("calls setupBloodhound", function() {
      spyOn(app.views.SearchBase.prototype, "setupBloodhound").and.callThrough();
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
      expect(app.views.SearchBase.prototype.setupBloodhound).toHaveBeenCalled();
    });

    it("doesn't call setupCustomSearch if customSearch hasn't been enabled", function() {
      spyOn(app.views.SearchBase.prototype, "setupCustomSearch");
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
      expect(app.views.SearchBase.prototype.setupCustomSearch).not.toHaveBeenCalled();
    });

    it("calls setupCustomSearch if customSearch has been enabled", function() {
      spyOn(app.views.SearchBase.prototype, "setupCustomSearch");
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q"), customSearch: true});
      expect(app.views.SearchBase.prototype.setupCustomSearch).toHaveBeenCalled();
    });

    it("calls setupTypeahead", function() {
      spyOn(app.views.SearchBase.prototype, "setupTypeahead");
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
      expect(app.views.SearchBase.prototype.setupTypeahead).toHaveBeenCalled();
    });

    it("initializes the array of diaspora ids that should be excluded from the search results", function() {
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
      expect(this.view.ignoreDiasporaIds.length).toBe(0);
    });

    it("doesn't call setupAutoselect if autoselect hasn't been enabled", function() {
      spyOn(app.views.SearchBase.prototype, "setupAutoselect");
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
      expect(app.views.SearchBase.prototype.setupAutoselect).not.toHaveBeenCalled();
    });

    it("calls setupAutoselect if autoselect has been enabled", function() {
      spyOn(app.views.SearchBase.prototype, "setupAutoselect");
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q"), autoselect: true});
      expect(app.views.SearchBase.prototype.setupAutoselect).toHaveBeenCalled();
    });

    it("calls setupTypeaheadAvatarFallback", function() {
      spyOn(app.views.SearchBase.prototype, "setupTypeaheadAvatarFallback");
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
      expect(app.views.SearchBase.prototype.setupTypeaheadAvatarFallback).toHaveBeenCalled();
    });
  });

  describe("bloodhoundTokenizer", function() {
    beforeEach(function() {
      this.view = new app.views.SearchBase({ el: "#search_people_form", typeaheadInput: $("#q") });
    });

    it("splits the string at whitespaces and punctuation chars", function() {
      expect(this.view.bloodhoundTokenizer("ab.c-d_ef g;h,i  #jkl?mnopq!rstu[vwx]::y(z){}")).toEqual(
        ["ab", "c", "d", "ef", "g", "h", "i", "jkl", "mnopq", "rstu", "vwx", "y", "z"]
      );
    });

    it("doesn't split the string at Cyrillic chars", function() {
      expect(this.view.bloodhoundTokenizer("АаБбВвГгДдЕеЁё ЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФф")).toEqual(
        ["АаБбВвГгДдЕеЁё", "ЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФф"]
      );
    });

    it("doesn't split the string at Malayalam chars", function() {
      expect(this.view.bloodhoundTokenizer("ബിപിൻദാസ്")).toEqual(
        ["ബിപിൻദാസ്"]
      );
    });

    it("returns an empty array inputs which are not a string", function() {
      expect(this.view.bloodhoundTokenizer(undefined)).toEqual([]);
      expect(this.view.bloodhoundTokenizer(null)).toEqual([]);
      expect(this.view.bloodhoundTokenizer(23)).toEqual([]);
      expect(this.view.bloodhoundTokenizer({foo: "bar"})).toEqual([]);
    });
  });

  describe("setupCustomSearch", function() {
    it("sets bloodhound.customSearch", function() {
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
      expect(this.view.bloodhound.customSearch).toBeUndefined();
      this.view.setupCustomSearch();
      expect(this.view.bloodhound.customSearch).toBeDefined();
    });

    describe("customSearch", function() {
      beforeEach(function() {
        this.view = new app.views.SearchBase({
          el: "#search_people_form",
          typeaheadInput: $("#q"),
          customSearch: true,
          remoteRoute: "/contacts"
        });
        this.view.bloodhound.search = function(query, sync, async) {
          sync([]);
          async(this.bloodhoundData);
        }.bind(this);
      });

      it("returns all results if none of them should be ignored", function() {
        var spy = jasmine.createSpyObj("callbacks", ["syncCallback", "asyncCallback"]);
        this.view.bloodhound.customSearch("user", spy.syncCallback, spy.asyncCallback);
        expect(spy.asyncCallback).toHaveBeenCalledWith(this.bloodhoundData);
      });

      it("doesn't return results that should be ignored", function() {
        var spy = jasmine.createSpyObj("callbacks", ["syncCallback", "asyncCallback"]);
        this.view.ignorePersonForSuggestions({handle: "user1@pod.tld"});
        this.view.bloodhound.customSearch("user", spy.syncCallback, spy.asyncCallback);
        expect(spy.asyncCallback).toHaveBeenCalledWith([this.bloodhoundData[1]]);
      });
    });
  });

  describe("transformBloodhoundResponse", function() {
    beforeEach(function() {
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
    });

    context("with persons", function() {
      beforeEach(function() {
        this.response = [{name: "Person", handle: "person@pod.tld"},{name: "User", handle: "user@pod.tld"}];
      });

      it("sets data.person to true", function() {
        expect(this.view.transformBloodhoundResponse(this.response)).toEqual([
         {name: "Person", handle: "person@pod.tld", person: true, link: false},
         {name: "User", handle: "user@pod.tld", person: true, link: false}
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

    context("with suggestionLink option set to true", function() {
      beforeEach(function() {
        this.view = new app.views.SearchBase({
          el: "#search_people_form",
          typeaheadInput: $("#q"),
          suggestionLink: true
        });

        this.response = [{name: "Person", handle: "person@pod.tld"}, {name: "User", handle: "user@pod.tld"}];
      });

      it("sets data.link to true", function() {
        expect(this.view.transformBloodhoundResponse(this.response)).toEqual([
          {name: "Person", handle: "person@pod.tld", person: true, link: true},
          {name: "User", handle: "user@pod.tld", person: true, link: true}
        ]);
      });
    });
  });

  describe("typeahead mouse events", function() {
    beforeEach(function() {
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
      this.view.bloodhound.add(this.bloodhoundData);
    });

    it("allows selecting results with the mouse", function() {
      this.search(this.view, "user");
      this.view.$(".tt-menu .tt-suggestion:eq(0)").trigger("mouseover");
      expect(this.view.$(".tt-menu .tt-suggestion:eq(0)")).toHaveClass("tt-cursor");
      expect(this.view.$(".tt-cursor").length).toBe(1);

      this.view.$(".tt-menu .tt-suggestion:eq(1)").trigger("mouseover");
      expect(this.view.$(".tt-menu .tt-suggestion:eq(1)")).toHaveClass("tt-cursor");
      expect(this.view.$(".tt-cursor").length).toBe(1);

      this.view.$(".tt-menu .tt-suggestion:eq(1)").trigger("mouseleave");
      expect(this.view.$(".tt-cursor").length).toBe(0);

      this.view.$(".tt-menu .tt-suggestion:eq(0)").trigger("mouseover");
      expect(this.view.$(".tt-menu .tt-suggestion:eq(0)")).toHaveClass("tt-cursor");
      expect(this.view.$(".tt-cursor").length).toBe(1);
    });
  });

  describe("_deselectAllSuggestions", function() {
    beforeEach(function() {
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
      this.view.bloodhound.add(this.bloodhoundData);
      this.search(this.view, "user");
    });

    it("deselects all suggestions", function() {
      $(".tt-suggestion").addClass(".tt-cursor");
      this.view._deselectAllSuggestions();
      expect($(".tt-suggestion.tt-cursor").length).toBe(0);

      $(".tt-suggestion:eq(1)").addClass(".tt-cursor");
      this.view._deselectAllSuggestions();
      expect($(".tt-suggestion.tt-cursor").length).toBe(0);
    });
  });

  describe("_selectSuggestion", function() {
    beforeEach(function() {
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
      this.view.bloodhound.add(this.bloodhoundData);
      this.search(this.view, "user");
    });

    it("selects a suggestion", function() {
      this.view._selectSuggestion($(".tt-suggestion:eq(1)"));
      expect($(".tt-suggestion.tt-cursor").length).toBe(1);
      expect($(".tt-suggestion:eq(1)")).toHaveClass("tt-cursor");
    });

    it("deselects all other suggestions", function() {
      spyOn(this.view, "_deselectAllSuggestions").and.callThrough();
      $(".tt-suggestion:eq(0)").addClass(".tt-cursor");
      this.view._selectSuggestion($(".tt-suggestion:eq(1)"));
      expect(this.view._deselectAllSuggestions).toHaveBeenCalled();
      expect($(".tt-suggestion.tt-cursor").length).toBe(1);
      expect($(".tt-suggestion:eq(1)")).toHaveClass("tt-cursor");
    });
  });

  describe("setupAutoSelect", function() {
    beforeEach(function() {
      this.view = new app.views.SearchBase({
        el: "#search_people_form",
        typeaheadInput: $("#q"),
        autoselect: true
      });
      this.view.bloodhound.add(this.bloodhoundData);
    });

    it("selects the first suggestion when showing the results", function() {
      this.search(this.view, "user");
      expect($(".tt-suggestion:eq(0)")).toHaveClass("tt-cursor");
      expect($(".tt-suggestion:eq(1)")).not.toHaveClass("tt-cursor");
    });
  });

  describe("setupTypeaheadAvatarFallback", function() {
    beforeEach(function() {
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
    });

    it("calls setupAvatarFallback when showing the results", function() {
      spyOn(this.view, "setupAvatarFallback");
      this.view.setupTypeaheadAvatarFallback();
      this.search(this.view, "user");
      expect(this.view.setupAvatarFallback).toHaveBeenCalled();
    });
  });

  describe("ignorePersonForSuggestions", function() {
    beforeEach(function() {
      this.view = new app.views.SearchBase({el: "#search_people_form", typeaheadInput: $("#q")});
    });

    it("adds the diaspora ids to the ignore list", function() {
      expect(this.view.ignoreDiasporaIds.length).toBe(0);
      this.view.ignorePersonForSuggestions({handle: "user1@pod.tld"});
      expect(this.view.ignoreDiasporaIds.length).toBe(1);
      this.view.ignorePersonForSuggestions({handle: "user2@pod.tld", someData: true});
      expect(this.view.ignoreDiasporaIds.length).toBe(2);
      expect(this.view.ignoreDiasporaIds).toEqual(["user1@pod.tld", "user2@pod.tld"]);
    });

    it("doesn't fail when the diaspora id is missing", function() {
      expect(this.view.ignoreDiasporaIds.length).toBe(0);
      this.view.ignorePersonForSuggestions({data: "user1@pod.tld"});
      expect(this.view.ignoreDiasporaIds.length).toBe(0);
    });
  });

  describe("render results", function() {
    beforeEach(function() {
      this.view = new app.views.SearchBase({
        el: "#search_people_form",
        typeaheadInput: $("#q"),
        autoselect: true,
        suggestionLink: true
      });

      this.view.bloodhound.add(this.view.transformBloodhoundResponse(this.bloodhoundData));
    });

    it("produces a link when initialized with suggestionLink option set to true", function() {
      this.view.typeaheadInput.typeahead("val", "user");
      this.view.typeaheadInput.typeahead("open");
      expect(this.view.suggestionLink).toBe(true);
      expect($(".search-suggestion-person").first().is("a")).toBe(true);
    });
  });
});
