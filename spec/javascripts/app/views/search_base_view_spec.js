describe("app.views.SearchBase", function() {
  beforeEach(function(){
    spec.content().html(
      "<form action='/search' id='search_people_form'><input id='q' name='q' type='search'/></form>"
    );
  });

  describe("initialize", function(){
    it("calls setupBloodhound", function(){
      spyOn(app.views.SearchBase.prototype, "setupBloodhound").and.callThrough();
      new app.views.SearchBase({el: "#search_people_form"});
      expect(app.views.SearchBase.prototype.setupBloodhound).toHaveBeenCalled();
    });

    it("calls setupTypeahead", function(){
      spyOn(app.views.SearchBase.prototype, "setupTypeahead");
      new app.views.SearchBase({el: "#search_people_form"});
      expect(app.views.SearchBase.prototype.setupTypeahead).toHaveBeenCalled();
    });

    it("calls bindSelectionEvents", function(){
      spyOn(app.views.SearchBase.prototype, "bindSelectionEvents");
      new app.views.SearchBase({el: "#search_people_form"});
      expect(app.views.SearchBase.prototype.bindSelectionEvents).toHaveBeenCalled();
    });

    it("initializes the results to filter", function(){
      spyOn(app.views.SearchBase.prototype, "bindSelectionEvents");
      var view = new app.views.SearchBase({el: "#search_people_form"});
      expect(view.resultsTofilter.length).toBe(0);
    });
  });

  describe("setupBloodhound", function(){
    beforeEach(function(){
      this.view = new app.views.SearchBase({el: "#search_people_form"});
      this.syncCallback = function(){};
      this.asyncCallback = function(){};
    });

    context("when performing a local search with 1 filtered result", function(){
      beforeEach(function(){
        this.view.initialize({typeaheadElement: this.view.$("#q")});
        this.view.bloodhound.add([
          {"id":1,"guid":"1","name":"user1","handle":"user1@pod.tld","url":"/people/1"},
          {"id":2,"guid":"2","name":"user2","handle":"user2@pod.tld","url":"/people/2"}
        ]);
      });

      it("should not return the filtered result", function(){
        spyOn(this, "syncCallback");
        spyOn(this, "asyncCallback");

        this.view.bloodhound.customSearch("user", this.syncCallback, this.asyncCallback);
        expect(this.syncCallback).toHaveBeenCalledWith([
          {"id":1,"guid":"1","name":"user1","handle":"user1@pod.tld","url":"/people/1"},
          {"id":2,"guid":"2","name":"user2","handle":"user2@pod.tld","url":"/people/2"}
        ]);
        expect(this.asyncCallback).not.toHaveBeenCalled();

        this.view.addToFilteredResults({"id":1,"guid":"1","name":"user1","handle":"user1@pod.tld","url":"/people/1"});
        this.view.bloodhound.customSearch("user", this.syncCallback, this.asyncCallback);
        expect(this.syncCallback).toHaveBeenCalledWith(
          [{"id":2,"guid":"2","name":"user2","handle":"user2@pod.tld","url":"/people/2"}]);
        expect(this.asyncCallback).not.toHaveBeenCalled();
      });
    });
  });

  describe("transformBloodhoundResponse", function() {
    beforeEach(function() {
      this.view = new app.views.SearchBase({ el: "#search_people_form" });
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

  describe("bindSelectionEvents", function(){
    beforeEach(function() {
      this.view = new app.views.SearchBase({ el: "#search_people_form" });
      this.view.initialize({typeaheadElement: this.view.$("#q")});
      this.view.bloodhound.add([
        {"person": true, "name":"user1", "handle":"user1@pod.tld"},
        {"person": true, "name":"user2", "handle":"user2@pod.tld"}
      ]);
    });

    context("bind over events", function(){
      it("binds over event only once", function(){
        this.view.$("#q").trigger("focusin");
        this.view.$("#q").val("user");
        this.view.$("#q").trigger("keypress");
        this.view.$("#q").trigger("input");
        this.view.$("#q").trigger("focus");
        var numBindedEvents = $._data(this.view.$(".tt-menu .tt-suggestion")[0], "events").mouseover.length;
        expect(numBindedEvents).toBe(1);
        this.view.$("#q").trigger("focusout");
        this.view.$("#q").trigger("focusin");
        this.view.$("#q").val("user");
        this.view.$("#q").trigger("keypress");
        this.view.$("#q").trigger("input");
        this.view.$("#q").trigger("focus");
        numBindedEvents = $._data(this.view.$(".tt-menu .tt-suggestion")[0], "events").mouseover.length;
        expect(numBindedEvents).toBe(1);
      });

      it("highlights the result when overing it", function(){
        this.view.$("#q").trigger("focusin");
        this.view.$("#q").val("user");
        this.view.$("#q").trigger("keypress");
        this.view.$("#q").trigger("input");
        this.view.$("#q").trigger("focus");
        this.view.$(".tt-menu .tt-suggestion").first().trigger("mouseover");
        expect(this.view.$(".tt-menu .tt-suggestion").first()).toHaveClass("tt-cursor");
      });
    });
  });

  describe("addToFilteredResults", function(){
    beforeEach(function() {
      this.view = new app.views.SearchBase({ el: "#search_people_form" });
      this.view.initialize({typeaheadElement: this.view.$("#q")});
    });

    context("when item is a person", function(){
      it("add the item to filtered results", function(){
        this.view.addToFilteredResults({handle: "user@pod.tld"});
        expect(this.view.resultsTofilter.length).toBe(1);
      });
    });

    context("when item is not a person", function(){
      it("does not add the item to filtered results", function(){
        this.view.addToFilteredResults({});
        expect(this.view.resultsTofilter.length).toBe(0);
      });
    });
  });

  describe("clearFilteredResults", function(){
    beforeEach(function() {
      this.view = new app.views.SearchBase({ el: "#search_people_form" });
      this.view.initialize({typeaheadElement: this.view.$("#q")});
    });

    context("clear filtered results", function(){
      it("clears the filtered results list", function(){
        this.view.addToFilteredResults({handle: "user@pod.tld"});
        expect(this.view.resultsTofilter.length).toBe(1);
        this.view.clearFilteredResults();
        expect(this.view.resultsTofilter.length).toBe(0);
      });
    });
  });
});
