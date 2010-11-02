/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/
$(document).ready(function() {
    $('div#image_picker div.small_photo').click( function() {
      var $this = $(this);
      document.getElementById("image_url_field").value = this.id;

      $('div#image_picker div.small_photo.selected').removeClass('selected')
        .children("input[type='checkbox']").attr("checked", false);

      $this.addClass('selected')
        .children("input[type='checkbox']").attr("checked", true);
    });
});
