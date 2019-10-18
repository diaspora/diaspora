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

    it('should show account and data management section', function(){
      this.view.$el.find('a[data-section=account_and_data_management]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_account_and_data_management')).toBeTruthy();
    });

    it('should show aspects section', function(){
      this.view.$el.find('a[data-section=aspects]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_aspects')).toBeTruthy();
    });

    it('should show mentions section', function(){
      this.view.$el.find('a[data-section=mentions]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_mentions')).toBeTruthy();
    });

    it('should show pods section', function(){
      this.view.$el.find('a[data-section=pods]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_pods')).toBeTruthy();
    });

    it('should show posts and posting section', function(){
      this.view.$el.find('a[data-section=posts_and_posting]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().data('template')).toBe('faq_posts_and_posting');
    });

    it('should show private posts section', function(){
      this.view.$el.find('a[data-section=private_posts]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_private_posts')).toBeTruthy();
    });

    it('should show public posts section', function(){
      this.view.$el.find('a[data-section=public_posts]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_public_posts')).toBeTruthy();
    });

    it('should show resharing posts section', function(){
      this.view.$el.find('a[data-section=resharing_posts]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_resharing_posts')).toBeTruthy();
    });

    it("should show profile section", function() {
      this.view.$el.find("a[data-section=profile]").trigger("click");
      expect(this.view.$el.find("#faq").children().first().hasClass("faq_question_profile")).toBeTruthy();
    });

    it('should show sharing section', function(){
      this.view.$el.find('a[data-section=sharing]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().data('template')).toBe('faq_sharing');
    });

    it('should show tags section', function(){
      this.view.$el.find('a[data-section=tags]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().data('template')).toBe('faq_tags');
    });

    it('should show keyboard shortcuts section', function(){
      this.view.$el.find('a[data-section=keyboard_shortcuts]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().data('template')).toBe('faq_keyboard_shortcuts');
    });

    it('should show miscellaneous section', function(){
      this.view.$el.find('a[data-section=miscellaneous]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_miscellaneous')).toBeTruthy();
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
