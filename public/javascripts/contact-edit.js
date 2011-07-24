//   Copyright (c) 2011, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var ContactEdit = {
  init: function(){
    Diaspora.widgets.subscribe('person/aspectMembershipUpdated',
      ContactEdit.updateUI, ContactEdit);

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

  toggleAspectMembership: function(li, evt) {
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
