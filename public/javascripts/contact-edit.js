//   Copyright (c) 2011, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var ContactEdit = {
  init: function(){
    $.extend(ContactEdit, AspectsDropdown);
    $('.dropdown.aspect_membership .dropdown_list > li').live('click', function(evt){
      ContactEdit.processClick($(this), evt);
    });
  },

  processClick: function(li, evt){
    var dropdown = li.closest('.dropdown');
    li.addClass('loading');
    if (dropdown.hasClass('inviter')) {
      ContactEdit.inviteFriend(li, evt);
    }
    else {
      ContactEdit.toggleAspectMembership(li, evt);
    }
  },

  inviteFriend: function(li, evt) {
    $.post('/services/inviter/facebook.json', {
      "aspect_id" : li.data("aspect_id"),
      "uid" : li.parent().data("service_uid")
    }, function(data){
      li.removeClass('loading')
      window.location = data.url;
    });
  },

  toggleAspectMembership: function(li, evt) {
    var button = li.find('.button');
    if(button.hasClass('disabled') || li.hasClass('newItem')){ return; }

    var selected = li.hasClass("selected"),
        routedId = selected ? "/42" : "";

    $.post("/aspect_memberships" + routedId + ".json", {
      "aspect_id": li.data("aspect_id"),
      "person_id": li.parent().data("person_id"),
      "_method": (selected) ? "DELETE" : "POST"
    }, function(aspectMembership) {
      li.removeClass('loading')
      ContactEdit.toggleCheckbox(li);
      ContactEdit.updateNumber(li.closest(".dropdown_list"), li.parent().data("person_id"), aspectMembership.aspect_ids.length, 'in_aspect');
      Diaspora.widgets.publish("aspectDropdown/updated", [li.parent().data("person_id"), li.parents(".dropdown").parent(".right").html()]);
    });
  },
};

$(document).ready(function(){
  ContactEdit.init();
});
