describe("app.views.AspectsList", function(){
  beforeEach(function(){
    setFixtures('<ul id="aspects_list"></ul>');
    var aspects  = [{ name: 'Work',          selected: true  },
                   { name: 'Friends',       selected: false },
                   { name: 'Acquaintances', selected: false }];
    this.aspects = new app.collections.AspectSelections(aspects);
    this.view    = new app.views.AspectsList({ collection: this.aspects });
  });

  describe('rendering', function(){
    beforeEach(function(){
      this.view.render();
    });

    it("should show the corresponding aspects selected", function(){
      expect(this.view.$(".selected").length).toBe(1);
      expect(this.view.$(".selected").parent().text()).toMatch("Work");
    });

    it("should show all the aspects", function(){
      var aspectSelectors = this.view.$(".entypo-check").parent();
      expect(aspectSelectors.length).toBe(3);
      expect(aspectSelectors[0].text).toMatch("Work");
      expect(aspectSelectors[1].text).toMatch("Friends");
      expect(aspectSelectors[2].text).toMatch("Acquaintances");
    });

    it('should show \'Select all\' link', function(){
      expect(this.view.$('.toggle_selector').text()).toMatch('Select all');
    });

    describe('selecting aspects', function(){
      context('selecting all aspects', function(){
        beforeEach(function(){
          app.router = new app.Router();
          spyOn(app.router, 'aspects_stream');
          spyOn(this.view, 'toggleAll').and.callThrough();
          spyOn(this.view, 'toggleSelector').and.callThrough();
          this.view.delegateEvents();
          this.view.$('.toggle_selector').click();
        });

        it('should show all the aspects selected', function(){
          expect(this.view.toggleAll).toHaveBeenCalled();
        });

        it('should show \'Deselect all\' link', function(){
          expect(this.view.toggleSelector).toHaveBeenCalled();
          expect(this.view.$('.toggle_selector').text()).toMatch('Deselect all');
        });
      });
    });
  });
});
