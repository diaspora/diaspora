describe("app.collections.AspectSelections", function() {
  beforeEach(function() {
    var myAspects = [
      {name: "Work", selected: true},
      {name: "Friends", selected: false},
      {name: "Acquaintances", selected: false}
    ];
    this.aspects = new app.collections.AspectSelections(myAspects);
  });

  describe("#selectAll", function() {
    it("selects every aspect in the collection", function() {
      this.aspects.selectAll();
      this.aspects.each(function(aspect) {
        expect(aspect.get("selected")).toBeTruthy();
      });
    });
  });

  describe("#deselectAll", function() {
    it("deselects every aspect in the collection", function() {
      this.aspects.deselectAll();
      this.aspects.each(function(aspect) {
        expect(aspect.get("selected")).toBeFalsy();
      });
    });
  });

  describe("#allSelected", function() {
    it("returns true if every aspect is selected", function() {
      this.aspects.at(1).set("selected", true);
      this.aspects.at(2).set("selected", true);
      expect(this.aspects.allSelected()).toBeTruthy();
    });

    it("returns false if at least one aspect is not selected", function() {
      expect(this.aspects.allSelected()).toBeFalsy();
    });
  });

  describe("#toSentence", function() {
    describe("with one aspect", function() {
      beforeEach(function() {
        this.aspects = new app.collections.AspectSelections([{name: "Work", selected: false}]);
      });

      it("returns 'My aspects' when the apsect isn't selected", function() {
        expect(this.aspects.toSentence()).toEqual("My aspects");
      });

      it("returns the name of the aspect when the aspect is selected", function() {
        this.aspects.at(0).set({selected: true});
        expect(this.aspects.toSentence()).toEqual("Work");
      });
    });

    describe("with three aspect", function() {
      it("returns the name of the selected aspect", function() {
        expect(this.aspects.toSentence()).toEqual("Work");
      });

      it("returns the names of the two selected aspects", function() {
        this.aspects.at(1).set("selected", true);
        expect(this.aspects.toSentence()).toEqual("Work and Friends");
      });

      it("returns the names of the selected aspects in a comma-separated sentence", function() {
        this.aspects.at(1).set("selected", true);
        this.aspects.at(2).set("selected", true);
        expect(this.aspects.toSentence()).toEqual("Work, Friends and Acquaintances");
      });
    });
  });

  describe("#selectedGetAttribute", function() {
    describe("by name", function() {
      it("returns the names of the selected aspects", function() {
        expect(this.aspects.selectedGetAttribute("name")).toEqual(["Work"]);
      });
    });
  });
});
