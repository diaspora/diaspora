//   Copyright (c) 2011, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var AspectsDropdown = {
  updateNumber: function(dropdown, personId, number, inAspectClass){
    var button = dropdown.parents(".dropdown").children('.button.toggle'),
        replacement;

    if (number == 0) {
      button.removeClass(inAspectClass);
      replacement = Diaspora.widgets.i18n.t("aspect_dropdown.toggle.zero");
    }else if (number == 1) { 
      button.addClass(inAspectClass);
      replacement = dropdown.find(".selected").first().text();
    }else if (number < 3) {
      replacement = Diaspora.widgets.i18n.t('aspect_dropdown.toggle.few', { count: number.toString()})
    }else if (number > 3) {
      replacement = Diaspora.widgets.i18n.t('aspect_dropdown.toggle.many', { count: number.toString()})
    }else {
      //the above one are a tautology, but I want to have them here once for once we figure out a neat way i18n them
      replacement = Diaspora.widgets.i18n.t('aspect_dropdown.toggle.other', { count: number.toString()})
    }

    button.html(replacement + ' ▼');
  },
  
  toggleCheckbox: 
    function(check){
      check.parent('li').toggleClass('selected');
    },
};

