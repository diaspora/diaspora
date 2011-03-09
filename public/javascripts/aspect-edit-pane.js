/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

function toggleAspectTitle(){
  $("#aspect_name_title").toggleClass('hidden');
  $("#aspect_name_edit").toggleClass('hidden');
}

$(document).ready(function() {
  $('#rename_aspect_link').live('click', function(){
    toggleAspectTitle();
  });

  $(".edit_aspect").live('ajax:success', function(data, json, xhr) {
    toggleAspectTitle();
  });
});
