describe("app.views.AspectsList", function(){
  beforeEach(function(){
    setFixtures('<ul id="aspects_list"></ul>');
    Diaspora.I18n.loadLocale({ aspect_navigation : {
      'select_all' : 'Select all',
      'deselect_all' : 'Deselect all'
    }});

    var aspects  = [{ name: 'Work',          selected: true  },
                   { name: 'Friends',       selected: false },
                   { name: 'Acquaintances', selected: false }];
    this.aspects = new app.collections.Aspects(aspects);
    this.view    = new app.views.AspectsList({ collection: this.aspects });
  });

  describe('rendering', function(){
    beforeEach(function(){
      this.view.render();
    });

    it('should show the corresponding aspects selected', function(){
      expect(this.view.$('.active').length).toBe(1);
      expect(this.view.$('.active > .aspect_selector').text()).toMatch('Work');
    });

    it('should show all the aspects', function(){
      var aspect_selectors = this.view.$('.aspect_selector');
      expect(aspect_selectors.length).toBe(3)
      expect(aspect_selectors[0].text).toMatch('Work');
      expect(aspect_selectors[1].text).toMatch('Friends');
      expect(aspect_selectors[2].text).toMatch('Acquaintances');
    });

    it('should show \'Select all\' link', function(){
      expect(this.view.$('.toggle_selector').text()).toMatch('Select all');
    });

    describe('selecting aspects', function(){
      context('selecting all aspects', function(){
        beforeEach(function(){
          app.router = new app.Router();
          spyOn(app.router, 'aspects_stream');
          spyOn(this.view, 'toggleAll').andCallThrough();
          spyOn(this.view, 'toggleSelector').andCallThrough();
          this.view.delegateEvents();
          this.view.$('.toggle_selector').click();
        });

        it('should show all the aspects selected', function(){
          expect(this.view.toggleAll).toHaveBeenCalled();
          expect(this.view.$('li.active').length).toBe(3);
        });

        it('should show \'Deselect all\' link', function(){
          expect(this.view.toggleSelector).toHaveBeenCalled();
          expect(this.view.$('.toggle_selector').text()).toMatch('Deselect all');
        });
      });
    });
  });
});
