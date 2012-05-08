//   Copyright (c) 2010-2011, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var ContactEdit = {
  init: function(){
    $.extend(ContactEdit, AspectsDropdown);
    $('.dropdown.aspect_membership .dropdown_list > li, .dropdown.inviter .dropdown_list > li').live('click', function(evt){
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
      ContactEdit.toggleAspectMembership(li, evt);
    }
  },

  inviteFriend: function(li, evt) {
    $.post('/services/inviter/facebook.json', {
      "aspect_id" : li.data("aspect_id"),
      "uid" : li.parent().data("service_uid")
    }, function(data){
      ContactEdit.processSuccess(li, evt, data);
    });
  },

  processSuccess: function(element, evt, data) {
    element.removeClass('loading')
    if (data.url != undefined) {
      window.location = data.url;
    } else {
      element.toggleClass("selected");
      Diaspora.widgets.flashes.render({'success':true, 'notice':data.message});
    }
  },

  processClick: function(li, evt){
    var dropdown = li.closest('.dropdown');
    li.addClass('loading');
    if (dropdown.hasClass('inviter')) {
      ContactEdit.inviteFriend(li, evt);
      dropdown.html('sending, please wait...');
    }
    else {
      ContactEdit.toggleAspectMembership(li, evt);
    }
  },

  toggleAspectMembership: function(li, evt) {
    var button = li.find('.button'),
        dropdown = li.closest('.dropdown'),
        dropdownList = li.parent('.dropdown_list');

    if(button.hasClass('disabled') || li.hasClass('newItem')){ return; }

    var selected = li.hasClass("selected"),
        routedId = selected ? "/42" : "";

    $.post("/aspect_memberships" + routedId + ".json", {
      "aspect_id": li.data("aspect_id"),
      "person_id": li.parent().data("person_id"),
      "_method": (selected) ? "DELETE" : "POST"
    }, function(aspectMembership) {
      ContactEdit.toggleCheckbox(li);
      ContactEdit.updateNumber(li.closest(".dropdown_list"), li.parent().data("person_id"), aspectMembership.aspect_ids.length, 'in_aspects');

      Diaspora.page.publish("aspectDropdown/updated", [li.parent().data("person_id"), li.parents(".dropdown").parent(".right").html()]);
    })
      .error(function() {
        var message = Diaspora.I18n.t("aspect_dropdown.error", {name: dropdownList.data('person-short-name')});
        Diaspora.page.flashMessages.render({success: false, notice: message});
        dropdown.removeClass('active');
      })
      .complete(function() {
        li.removeClass("loading");
      });
  }
};

$(document).ready(function(){
  ContactEdit.init();
});
