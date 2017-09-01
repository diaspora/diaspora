describe("app.views.AspectsDropdown", function(){
  beforeEach(function() {
    spec.loadFixture("bookmarklet");
    this.view = new app.views.AspectsDropdown({el: $('.aspect-dropdown')});
  });

  context('_toggleCheckbox', function() {
    beforeEach(function() {
      this.view.$("li.selected").removeClass("selected");
      this.view.$("li.all_aspects").addClass("selected");
    });

    it('deselects all radio buttons', function() {
      this.view._toggleCheckbox(this.view.$('li.aspect_selector:eq(0)'));
      expect(this.view.$('li.all_aspects.radio').hasClass('selected')).toBeFalsy();
    });

    it('selects the clicked aspect', function() {
      this.view._toggleCheckbox(this.view.$('li.aspect_selector:eq(0)'));
      expect(this.view.$('li.aspect_selector:eq(0)').hasClass('selected')).toBeTruthy();
    });

    it('selects multiple aspects', function() {
      this.view._toggleCheckbox(this.view.$('li.aspect_selector:eq(0)'));
      this.view._toggleCheckbox(this.view.$('li.aspect_selector:eq(1)'));
      expect(this.view.$('li.aspect_selector:eq(0)').hasClass('selected')).toBeTruthy();
      expect(this.view.$('li.aspect_selector:eq(1)').hasClass('selected')).toBeTruthy();
    });
  });

  context('_toggleRadio', function(){
    beforeEach(function() {
      this.view.$('li.selected').removeClass('selected');
      this.view.$('li.aspect_selector:eq(0)').addClass('selected');
      this.view.$('li.aspect_selector:eq(1)').addClass('selected');
    });

    it('deselects all checkboxes', function() {
      this.view._toggleRadio(this.view.$("li.all_aspects"));
      expect(this.view.$("li.aspect_selector:eq(0)").hasClass("selected")).toBeFalsy();
      expect(this.view.$("li.aspect_selector:eq(1)").hasClass("selected")).toBeFalsy();
    });

    it('toggles the clicked radio buttons', function() {
      this.view._toggleRadio(this.view.$("li.all_aspects"));
      expect(this.view.$("li.all_aspects").hasClass("selected")).toBeTruthy();
      expect(this.view.$("li.public").hasClass("selected")).toBeFalsy();
      this.view._toggleRadio(this.view.$("li.public"));
      expect(this.view.$("li.all_aspects").hasClass("selected")).toBeFalsy();
      expect(this.view.$("li.public").hasClass("selected")).toBeTruthy();
      this.view._toggleRadio(this.view.$("li.all_aspects"));
      expect(this.view.$("li.all_aspects").hasClass("selected")).toBeTruthy();
      expect(this.view.$("li.public").hasClass("selected")).toBeFalsy();
    });
  });

  context("_selectAspects", function(){
    beforeEach(function() {
      this.view.$("li.selected").removeClass("selected");
      this.view.$("li.aspect_selector:eq(0)").addClass("selected");
    });

    it("select aspects in the dropdown by a given list of ids", function() {
      this.ids = [this.view.$("li.aspect_selector:eq(1)").data("aspect_id"),"public"];
      this.view._selectAspects(this.ids);
      expect(this.view.$("li.all_aspects").hasClass("selected")).toBeFalsy();
      expect(this.view.$("li.public").hasClass("selected")).toBeTruthy();
      expect(this.view.$("li.aspect_selector:eq(0)").hasClass("selected")).toBeFalsy();
      expect(this.view.$("li.aspect_selector:eq(1)").hasClass("selected")).toBeTruthy();
    });
  });

  context("_updateButton", function() {
    beforeEach(function() {
      this.view.$("li.selected").removeClass("selected");
    });

    it("shows 'Select aspects' when nothing is selected", function() {
      this.view._updateButton("inAspectClass");
      expect(this.view.$(".btn.dropdown-toggle > .text").text()).toContain(
        Diaspora.I18n.t("aspect_dropdown.select_aspects")
      );
    });

    it("shows the name of the selected radio button", function() {
      this.view.$("li.all_aspects").addClass("selected");
      this.view._updateButton("inAspectClass");
      expect(this.view.$(".btn.dropdown-toggle > .text").text()).toContain(
        Diaspora.I18n.t("aspect_dropdown.all_aspects")
      );
    });

    it("shows the name of the selected aspect ( == 1 )", function() {
      this.view.$("li.aspect_selector:eq(1)").addClass("selected");
      this.view._updateButton("inAspectClass");
      expect(this.view.$(".btn.dropdown-toggle > .text").text()).toContain(
        this.view.$("li.aspect_selector:eq(1) .text").text()
      );
    });

    it("shows the number of selected aspects ( > 1)", function() {
      this.view.$("li.aspect_selector:eq(0)").addClass("selected");
      this.view.$("li.aspect_selector:eq(1)").addClass("selected");
      this.view._updateButton("inAspectClass");
      expect(this.view.$(".btn.dropdown-toggle > .text").text()).toContain(
        Diaspora.I18n.t("aspect_dropdown.toggle", { count: 2 })
      );
    });
  });
});
