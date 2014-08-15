describe("app.collections.Aspects", function(){
  beforeEach(function(){
    Diaspora.I18n.load({
      'and' : "and",
      'comma' : ",",
      'my_aspects' : "My Aspects"
    });
    var my_aspects = [{ name: 'Work',          selected: true  },
                      { name: 'Friends',       selected: false },
                      { name: 'Acquaintances', selected: false }]
    this.aspects = new app.collections.Aspects(my_aspects);
  });

  describe("#selectAll", function(){
    it("selects every aspect in the collection", function(){
      this.aspects.selectAll();
      this.aspects.each(function(aspect){
        expect(aspect.get('selected')).toBeTruthy();
      });
    });
  });

  describe("#deselectAll", function(){
    it("deselects every aspect in the collection", function(){
      this.aspects.deselectAll();
      this.aspects.each(function(aspect){
        expect(aspect.get('selected')).toBeFalsy();
      });
    });
  });

  describe("#allSelected", function(){
    it("returns true if every aspect is selected", function(){
      this.aspects.at(1).set('selected', true);
      this.aspects.at(2).set('selected', true);
      expect(this.aspects.allSelected()).toBeTruthy();
    });

    it("returns false if at least one aspect is not selected", function(){
      expect(this.aspects.allSelected()).toBeFalsy();
    });
  });

  describe("#toSentence", function(){
    describe('without aspects', function(){
      beforeEach(function(){
        this.aspects = new app.collections.Aspects({ name: 'Work', selected: false })
        spyOn(this.aspects, 'selectedAspects').andCallThrough();
      });

      it("returns the name of the aspect", function(){
        expect(this.aspects.toSentence()).toEqual('My Aspects');
        expect(this.aspects.selectedAspects).toHaveBeenCalled();
      });
    });

    describe("with one aspect", function(){
      beforeEach(function(){
        this.aspects = new app.collections.Aspects({ name: 'Work', selected: true })
        spyOn(this.aspects, 'selectedAspects').andCallThrough();
      });

      it("returns the name of the aspect", function(){
        expect(this.aspects.toSentence()).toEqual('Work');
        expect(this.aspects.selectedAspects).toHaveBeenCalled();
      });
    });

    describe("with three aspect", function(){
      it("returns the name of the selected aspect", function(){
        expect(this.aspects.toSentence()).toEqual('Work');
      });

      it("returns the names of the two selected aspects", function(){
        this.aspects.at(1).set('selected', true);
        expect(this.aspects.toSentence()).toEqual('Work and Friends');
      });

      it("returns the names of the selected aspects in a comma-separated sentence", function(){
        this.aspects.at(1).set('selected', true);
        this.aspects.at(2).set('selected', true);
        expect(this.aspects.toSentence()).toEqual('Work, Friends and Acquaintances');
      });
    });
  });

  describe("#selectedAspects", function(){
    describe("by name", function(){
      it("returns the names of the selected aspects", function(){
        expect(this.aspects.selectedAspects('name')).toEqual(["Work"]);
      });
    });
  });
});
