//   Copyright (c) 2011, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var ContactEdit = {
  init: function(){
    Diaspora.widgets.subscribe('person/aspectMembershipUpdated',
      ContactEdit.updateUI, ContactEdit);

    $('.dropdown .dropdown_list > li').live('click', function(evt){
      ContactEdit.processClick($(this), evt);
    });
  },

  updateNumber: function(dropdown, personId, number){
    var button = dropdown.parents(".dropdown").children('.button.toggle'),
        replacement;

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
      //the above one are a tautology, but I want to have them here once for once we figure out a neat way i18n them
      replacement = Diaspora.widgets.i18n.t('aspect_dropdown.toggle.other', { count: number.toString()})
    }

    button.html(replacement + ' ▼');
  },
  
  toggleCheckbox: function(check){
      check.parent('li').toggleClass('selected');
    },

  checkCheckbox: function(check){
      check.parent('li').addClass('selected');
    },

  uncheckCheckbox: function(check){
      check.parent('li').removeClass('selected');
    },

  updateUI: function(evt, aspectMembership) {
    var pid = aspectMembership.person_id;
        aspects = aspectMembership.aspect_ids;

    var dropdown_lists = $('.dropdown_list[data-person_id="'+pid+'"]');
    dropdown_lists.each(function(liIdx){
      ContactEdit.updateNumber($(this), pid, aspects.length);
      ContactEdit.updateCheckboxes(pid, aspects, $(this));
    });
  },

  updateCheckboxes: function(personId, activeIds, dropdown_list){
    dropdown_list.find('li[data-aspect_id]').each(function(liIdx){
      li = $(this);
      if($.inArray(parseInt(li.attr('data-aspect_id')), activeIds)>-1)
        ContactEdit.checkCheckbox(li.find('img.check'));
      else
        ContactEdit.uncheckCheckbox(li.find('img.check'));
    });
  },

  processClick: function(li, evt){
    var button = li.find('.button');
    if(button.hasClass('disabled') || li.hasClass('newItem')){ return; }

    var selected = li.hasClass("selected"),
        person_id = li.parent().data("person_id"),
        aspect_id = li.data("aspect_id");

    if(selected)
      Diaspora.ajax.remove_person_from_aspect(person_id, aspect_id);
    else
      Diaspora.ajax.add_person_to_aspect(person_id, aspect_id);
  },
};

$(document).ready(function(){
  ContactEdit.init();
});
