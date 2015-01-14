/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(document).ready(function() {
  $('#aspect_nav.left_nav .all_aspects .sub_nav').sortable({
    items: "li[data-aspect_id]",
    update: function(event, ui) {
      var order = $(this).sortable("toArray", {attribute: "data-aspect_id"}),
          obj = { 'reorder_aspects': order, '_method': 'put' };
      $.ajax('/user', { type: 'post', dataType: 'script', data: obj });
    },
    revert: true,
    helper: 'clone'
  });
});

