/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(document).ready(function() {
  $('#aspect_nav .nav').sortable({
    items: "li.aspect[data-aspect-id]",
    update: function(event, ui) {
      var order = $(this).sortable("toArray", {attribute: "data-aspect-id"}),
          obj = { 'aspect_order': order };
      $.ajax('/user', { type: 'put', dataType: 'text', data: obj });
    },
    revert: true,
    helper: 'clone'
  });
});
