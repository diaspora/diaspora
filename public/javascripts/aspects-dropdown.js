//   Copyright (c) 2010-2011, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var AspectsDropdown = {
  updateNumber: function(dropdown, personId, number, inAspectClass){
    var button = dropdown.parents(".dropdown").children('.button.toggle'),
        selectedAspects = dropdown.children(".selected").length,
        allAspects = dropdown.children('li[data-aspect_id]').length,
        replacement,
        toggleButtonReplacement = Diaspora.I18n.t("aspect_navigation.select_all");
    
    var toggleButton = dropdown.children('.toggleSelection');

    if (number == 0) {
      button.removeClass(inAspectClass);
      
      if( dropdown.closest('#publisher').length ) {
        replacement = Diaspora.I18n.t("aspect_dropdown.select_aspects");
      } else {
        replacement = Diaspora.I18n.t("aspect_dropdown.add_to_aspect");
      }
      
      toggleButtonReplacement = Diaspora.I18n.t("aspect_navigation.select_all");
    }else if (selectedAspects == allAspects) {
      replacement = Diaspora.I18n.t('aspect_dropdown.all_aspects');
      toggleButtonReplacement = Diaspora.I18n.t("aspect_navigation.deselect_all");
    }else if (number == 1) {
      button.addClass(inAspectClass);
      replacement = dropdown.find(".selected").first().text();
    }else if (number < 3) {
      replacement = Diaspora.I18n.t('aspect_dropdown.toggle.few', { count: number.toString()})
    }else if (number > 3) {
      replacement = Diaspora.I18n.t('aspect_dropdown.toggle.many', { count: number.toString()})
    }else {
      //the above one are a tautology, but I want to have them here once for once we figure out a neat way i18n them
      replacement = Diaspora.I18n.t('aspect_dropdown.toggle.other', { count: number.toString()})
    }

    button.text(replacement + ' ▼');
    toggleButton.children('span').text(toggleButtonReplacement);
  },
  
  toggleSelection: function(dropdown) {
    dropdown.children('li[data-aspect_id]').toggleClass(
      'selected',
      dropdown.children('li.selected[data-aspect_id]').length == 0
    );
  },
  
  toggleCheckbox: function(check) {
    if(check.hasClass('toggleSelection')) {
      this.toggleSelection(check.parent());
    }
    else {
      check.toggleClass('selected');
    }
  }
};

