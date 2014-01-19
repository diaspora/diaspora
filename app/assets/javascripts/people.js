/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
//= require aspect-edit-pane
//= require fileuploader-custom
//= require jquery.autoSuggest.custom

$(document).ready(function() {
  $('#profile_buttons .profile_button div').tooltip({placement: 'bottom'});
  $('#profile_buttons .sharing_message_container').tooltip({placement: 'bottom'});
  $("#block_user_button").click(function(evt) {
    if(!confirm(Diaspora.I18n.t('ignore_user'))) { return; }
      var personId = $(this).data('person-id');
      var block = new app.models.Block();
      block.save({block : {person_id : personId}}, {
        success: function() {
          $('#profile_buttons').attr('class', 'blocked');
          $('#sharing_message').attr('class', 'icons-circle');
          $('.profile_button, .white_bar').remove();
        }
      });

      return false;
   });
});
