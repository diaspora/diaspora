describe("Diaspora.Widgets.AspectsDropdown", function() {
  var aspectsDropdownWidget,
    aspectsDropdown;

  describe("when the dropdown is a publisher dropdown", function() {
    beforeEach(function() {
      spec.loadFixture("aspects_index");

      Diaspora.Page = "TestPage";
      Diaspora.instantiatePage();

      aspectsDropdown = $("#publisher .dropdown");
      aspectsDropdownWidget = Diaspora.BaseWidget.instantiate("AspectsDropdown", aspectsDropdown);
    });

    describe("clicking a radio button", function() {
      describe("integration", function() {
        it("calls AspectsDropdown#radioClicked", function() {
          aspectsDropdownWidget = new Diaspora.Widgets.AspectsDropdown();

          spyOn(aspectsDropdownWidget, "radioClicked");

          aspectsDropdownWidget.publish("widget/ready", [aspectsDropdown]);

          aspectsDropdownWidget.radioSelectors.first().click();

          expect(aspectsDropdownWidget.radioClicked).toHaveBeenCalled();
        })
      });

      it("clears the selected aspects", function() {
        var aspectSelectors = aspectsDropdown.find(".aspect_selector").click();

        expect(aspectsDropdown).toContain("li.aspect_selector.selected");

        aspectsDropdown.find(".radio:first").click();

        expect(aspectsDropdown).not.toContain("li.aspect_selector.selected");
      });

      it("clears selected radio buttons", function() {
        aspectsDropdown.find(".selected").removeClass("selected");

        var firstRadioSelector = aspectsDropdown.find(".radio:first"),
          lastRadioSelector = aspectsDropdown.find(".radio:last");

        expect(firstRadioSelector).not.toHaveClass("selected");
        expect(lastRadioSelector).not.toHaveClass("selected");

        firstRadioSelector.click();

        expect(firstRadioSelector).toHaveClass("selected");

        lastRadioSelector.click();

        expect(firstRadioSelector).not.toHaveClass("selected");
        expect(lastRadioSelector).toHaveClass("selected");
      });

      it("toggles the radio selector", function() {
        var radioSelector = aspectsDropdown.find(".radio:first");

        expect(radioSelector).not.toHaveClass("selected");

        radioSelector.click();

        expect(radioSelector).toHaveClass("selected");

        radioSelector.click();

        expect(radioSelector).not.toHaveClass("selected");
      });
    });

    describe("clicking an aspect", function() {
      describe("integration", function() {
        it("calls through to AspectsDropdown#toggleAspectSelection", function() {
          aspectsDropdownWidget = new Diaspora.Widgets.AspectsDropdown();

          spyOn(aspectsDropdownWidget, "toggleAspectSelection");

          aspectsDropdownWidget.publish("widget/ready", [aspectsDropdown]);

          aspectsDropdownWidget.aspectSelectors.first().click();

          expect(aspectsDropdownWidget.toggleAspectSelection).toHaveBeenCalled();
        });
      });

      it("deselects the radio buttons", function() {
        var aspectSelector = aspectsDropdownWidget.aspectSelectors.first(),
          radioSelector = aspectsDropdown.find(".radio:last");

        expect(radioSelector).toHaveClass("selected");

        aspectSelector.click();

        expect(radioSelector).not.toHaveClass("selected");
      });

      it("toggles the aspect selector", function() {
        var aspectSelector = aspectsDropdownWidget.aspectSelectors.first();

        expect(aspectSelector).not.toHaveClass("selected");

        aspectSelector.click();

        expect(aspectSelector).toHaveClass("selected");

        aspectSelector.click();

        expect(aspectSelector).not.toHaveClass("selected");
      });
    });
  });
});