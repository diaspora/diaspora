/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

function toggleAspectTitle(){
  $("#aspect_name_title").toggleClass('hidden');
  $("#aspect_name_edit").toggleClass('hidden');
}

function updateAspectName(new_name) {
  $('#aspect_name_title .name').html(new_name);
  $('input#aspect_name').val(new_name);
}

$(document).ready(function() {
  $('#rename_aspect_link').live('click', function(){
    toggleAspectTitle();
  });

  $('form.edit_aspect').live('ajax:success', function(evt, data, status, xhr) {
    updateAspectName(data['name']);
    toggleAspectTitle();
  });
});
