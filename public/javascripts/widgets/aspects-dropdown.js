/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function() {
  var AspectsDropdown = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, dropdown) {
      $.extend(self, {
        aspectSelectors: dropdown.find("li.aspect_selector"),
        radioSelectors: dropdown.find("li.radio"),
        dropdown: dropdown,
        dropdownButton: dropdown.children(".button.toggle"),
        dropdownList: dropdown.find("ul.dropdown_list"),
        inviterDropdown: dropdown.hasClass("inviter"),
        publisherDropdown: !!dropdown.closest("#publisher").length
      });

      self.personId = self.dropdownList.data("person_id");

      self.aspectSelectors.click(self.aspectClicked);
      self.radioSelectors.click(self.radioClicked);
    });

    this.aspectClicked = function(evt) {
      var aspectListItem = $(this);
      if (self.inviterDropdown) {
        self.inviteFriend(aspectListItem);
      }
      else if(self.publisherDropdown) {
        self.toggleAspectSelection(aspectListItem);
      }
      else {
        self.toggleAspectMembership(aspectListItem);
      }
    };

    this.radioClicked = function() {
      self.aspectSelectors
        .add(self.radioSelectors)
        .not(this)
        .removeClass("selected");

      $(this).toggleClass("selected")
    };

    this.toggleAspectSelection = function(aspect) {
      self.radioSelectors.removeClass("selected");

      aspect.toggleClass("selected");
    };

    this.inviteFriend = function(aspectListItem) {
      self.dropdown.html(Diaspora.I18n.t("inviter.sending"));
      $.post('/services/inviter/facebook.json', {
        "aspect_id" : aspectListItem.data("aspect_id"),
        "uid" : self.dropdownList.data("service_uid")
      }, function(data) {
        aspectListItem.removeClass("loading");
        if (typeof data.url !== "undefined") {
          window.location = data.url;
        } else {
          aspectListItem.toggleClass("selected");

          Diaspora.page.flashMessages.render({
            success: true,
            notice: data.message
          });
        }
      });
    };

    this.toggleAspectMembership = function(aspectListItem) {
      var aspectId = aspectListItem.data("aspect_id"),
        button = aspectListItem.find(".button");

      if(button.hasClass("disabled") || aspectListItem.hasClass("newItem")) { return; }

      var selected = aspectListItem.hasClass("selected"),
        routedId = selected ? "/42" : "";

      aspectListItem.addClass("loading");

      $.post("/aspect_memberships" + routedId + ".json", {
        "aspect_id": aspectId,
        "person_id": self.personId,
        "_method": (selected) ? "DELETE" : "POST"
      }, function() {
        aspectListItem.removeClass("loading")
          .toggleClass("selected");

        self.updateDropdownText();

        self.globalPublish("aspectDropdown/updated", [self.personId, self.dropdown.parent().html()]);
      });
    };

    this.updateDropdownText = function() {
      var selectedAspects = self.dropdownList.children(".selected").length,
        allAspects = self.dropdownList.children().length,
        replacement;

      if (selectedAspects == 0) {
        self.dropdownButton.removeClass("in_aspects");

        if(self.dropdown.closest("#publisher").length) {
          replacement = Diaspora.I18n.t("aspect_dropdown.select_aspects");
        } else {
          replacement = Diaspora.I18n.t("aspect_dropdown.add_to_aspect");
        }
      }
      else if (selectedAspects === allAspects) {
        replacement = Diaspora.I18n.t("aspect_dropdown.all_aspects");
      }
      else if (selectedAspects === 1) {
        self.dropdownButton.addClass("in_aspects");

        replacement = self.dropdown.find(".selected:first").text();
      }
      else if (selectedAspects > 1) {
        replacement = Diaspora.I18n.t("aspect_dropdown.toggle", {
          count: selectedAspects
        });
      }

      self.dropdownButton.text(replacement + " ▼");
    }
  };

  Diaspora.Widgets.AspectsDropdown = AspectsDropdown;
})();