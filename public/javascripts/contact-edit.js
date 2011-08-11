//   Copyright (c) 2011, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var ContactEdit = {
  init: function(){
    $('.dropdown .dropdown_list > li').live('click', function(evt){
      ContactEdit.processClick($(this), evt);
    });
  },

  updateNumber: function(dropdown, personId, number){
    var button = dropdown.parents(".dropdown").children('.button.toggle'),
        replacement;

    if (number == 0) {
      button.removeClass("in_aspects");
      replacement = Diaspora.I18n.t("aspect_dropdown.toggle.zero");
    }else if (number == 1) { 
      button.addClass("in_aspects");
      replacement = dropdown.find(".selected").first().text();
    }else if (number < 3) {
      replacement = Diaspora.I18n.t('aspect_dropdown.toggle.few', { count: number.toString()})
    }else if (number > 3) {
      replacement = Diaspora.I18n.t('aspect_dropdown.toggle.many', { count: number.toString()})
    }else {
      //the above one are a tautology, but I want to have them here once for once we figure out a neat way i18n them
      replacement = Diaspora.I18n.t('aspect_dropdown.toggle.other', { count: number.toString()})
    }

    button.html(replacement + ' ▼');
  },
  
  toggleCheckbox: 
    function(check){
      check.parent('li').toggleClass('selected');
    },

  processClick: function(li, evt){
    var button = li.find('.button');
    if(button.hasClass('disabled') || li.hasClass('newItem')){ return; }

    var checkbox = li.find('img.check'),
        selected = li.hasClass("selected"),
        routedId = selected ? "/42" : "";

    $.post("/aspect_memberships" + routedId + ".json", {
      "aspect_id": li.data("aspect_id"),
      "person_id": li.parent().data("person_id"),
      "_method": (selected) ? "DELETE" : "POST"
    }, function(aspectMembership) {
      ContactEdit.toggleCheckbox(checkbox);
      ContactEdit.updateNumber(li.closest(".dropdown_list"), li.parent().data("person_id"), aspectMembership.aspect_ids.length);

      Diaspora.Page.publish("aspectDropdown/updated", [li.parent().data("person_id"), li.parents(".dropdown").parent(".right").html()]);
    });
  },
};

  $(document).ready(function(){
    ContactEdit.init();
  });
