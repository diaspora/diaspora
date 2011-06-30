//   Copyright (c) 2011, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var ContactEdit = {
  init: function(){
    $('.dropdown .dropdown_list > li').live('click', function(evt){
      ContactEdit.processClick($(this), evt);
    });
  },

  updateNumber: function(personId){
    var dropdown = $(".dropdown_list[data-person_id=" + personId.toString() +"]"),
        number = dropdown.find(".selected").length,
        button = dropdown.parents(".dropdown").children('.button.toggle');

    var replacement;

    if (number == 0) {
      button.removeClass("in_aspects");
      replacement = Diaspora.widgets.i18n.t("aspect_dropdown.toggle.zero");
    }else if (number == 1) { 
      button.addClass("in_aspects");
      replacement = dropdown.find(".selected").first().text();
    }else if (number < 3) {
      replacement = Diaspora.widgets.i18n.t('aspect_dropdown.toggle.few', { count: number.toString()})
    }else if (number > 3) {
      replacement = Diaspora.widgets.i18n.t('aspect_dropdown.toggle.many', { count: number.toString()})
    }else {
      //the above one are a totalogy, but I want to have them here once for once we figure out a neat way i18n them
      replacement = Diaspora.widgets.i18n.t('aspect_dropdown.toggle.other', { count: number.toString()})
    }

    button.html(replacement + ' ▼');
  },
  
  toggleCheckbox: 
    function(check){
      check.toggleClass('hidden');
      check.parent('li').toggleClass('selected');
    },

  processClick: function(li, evt){
    var button = li.find('.button');
    if(button.hasClass('disabled') || li.hasClass('newItem')){ return; }

    var checkbox = li.find('img.check');
    ContactEdit.toggleCheckbox(checkbox);

    $.fn.callRemote.apply(button);
  },
};

  $(document).ready(function(){
    ContactEdit.init();
  });
