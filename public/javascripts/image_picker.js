/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/


$(document).ready( function() {
    $('div#image_picker div.small_photo').click( function() {
      $('#image_url_field').val($(this).attr('id'));

      $('div#image_picker div.small_photo').removeClass('selected');
      $("div#image_picker div.small_photo input[type='checkbox']").attr("checked", false);

      $(this).addClass('selected');
      $(this).children("input[type='checkbox']").attr("checked", true);
    });
});
