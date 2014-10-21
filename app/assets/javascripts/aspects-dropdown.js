// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

//   Copyright (c) 2010-2012, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var AspectsDropdown = {
  updateNumber: function(dropdown, personId, number, inAspectClass){
    var button = dropdown.parents(".dropdown").children('.button.toggle'),
        selectedAspects = dropdown.children(".selected").length,
        allAspects = dropdown.children().length,
        replacement,
        isInPublisher = dropdown.closest('#publisher').length;

    if (number == 0) {
      button.removeClass(inAspectClass);
      if (isInPublisher) {
        replacement = Diaspora.I18n.t("aspect_dropdown.select_aspects");
      } else {
        replacement = Diaspora.I18n.t("aspect_dropdown.add_to_aspect");
        /* flash message prompt */
        var message = Diaspora.I18n.t("aspect_dropdown.stopped_sharing_with", {name: dropdown.data('person-short-name')});
        Diaspora.page.flashMessages.render({success: true, notice: message});
      }
    } else if (selectedAspects == allAspects) {
      replacement = Diaspora.I18n.t('aspect_dropdown.all_aspects');
    } else if (number == 1) {
      button.addClass(inAspectClass);
      replacement = dropdown.find(".selected").first().text();
      /* flash message prompt */
      if (!isInPublisher) {
        var message = Diaspora.I18n.t("aspect_dropdown.started_sharing_with", {name: dropdown.data('person-short-name')});
        Diaspora.page.flashMessages.render({success: true, notice: message});
      }
    } else {
      replacement = Diaspora.I18n.t('aspect_dropdown.toggle', { count: number.toString()})
    }

    // if we are in the publisher, we add the visibility icon
    if (isInPublisher) {
      var icon = $('#visibility-icon');      
      if (replacement.trim() == Diaspora.I18n.t('stream.public')) {
        icon.removeClass('lock');
        icon.addClass('globe');
      } else {
        icon.removeClass('globe');
        icon.addClass('lock');
      }
      button.find('.text').text(replacement);
    } else {
      button.text(replacement + ' ▼');
    }
  },

  toggleCheckbox: function(check) {
    if(!check.hasClass('radio')){
      var selectedAspects = check.closest(".dropdown").find("li.radio");
      AspectsDropdown.uncheckGroup(selectedAspects);
    }

    check.toggleClass('selected');
  },

  toggleRadio: function(check) {
    var selectedAspects = check.closest(".dropdown").find("li");

    AspectsDropdown.uncheckGroup(selectedAspects);
    AspectsDropdown.toggleCheckbox(check);
  },

  uncheckGroup: function(elements){
    $.each(elements, function(index, value) {
      $(value).removeClass('selected');
    });
  }
};

// @license-end

