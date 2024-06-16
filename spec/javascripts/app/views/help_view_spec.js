describe("app.views.Help", function(){
  beforeEach(function(){
    this.locale = JSON.parse(spec.readFixture("locale_en_help_json"));
    Diaspora.I18n.reset();
    Diaspora.I18n.load(this.locale, "en");
    this.view = new app.views.Help();
    Diaspora.Page = "HelpFaq";
  });

  afterEach(function() {
    Diaspora.I18n.reset();
    Diaspora.I18n.load(spec.defaultLocale);
  });

  describe("render", function(){
    beforeEach(function(){
      this.view.render();
    });

    it('should initially show getting help section', function(){
      expect(this.view.$el.find('#faq').children().first().data('template')).toBe('faq_getting_help');
    });
  });

  describe("findSection", function() {
    beforeEach(function() {
      this.view.render();
    });

    it('should return null for an unknown section', function() {
      expect(this.view.findSection('you_shall_not_pass')).toBeNull();
    });

    it('should return the correct section link for existing sections', function() {
      var sections = [
        'account_and_data_management',
        'aspects',
        'pods',
        'keyboard_shortcuts',
        'tags',
        'miscellaneous'
      ];

      var self = this;
      _.each(sections, function(section) {
        var el = self.view.$el.find('a[data-section=' + section + ']');
        expect(self.view.findSection(section).html()).toBe(el.html());
      });
    });
  });

  describe("menuClicked", function() {
    beforeEach(function() {
      this.view.render();
    });

    it('should rewrite the location', function(){
      var sections = [
        'account_and_data_management',
        'miscellaneous'
      ];
      spyOn(app.router, 'navigate');

      var self = this;
      _.each(sections, function(section) {
        self.view.$el.find('a[data-section=' + section + ']').trigger('click');
        expect(app.router.navigate).toHaveBeenCalledWith('help/' + section);
      });
    });
  });
});
