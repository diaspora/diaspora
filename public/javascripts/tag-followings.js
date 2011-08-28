/*   Copyright (c) 2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

var TagFollowings = {
  initialize: function(){
    $('.unfollow').live('mouseenter', function(){
      $(this).find('.unfollow_icon').removeClass('hidden');
    }).live('mouseleave', function(){
      $(this).find('.unfollow_icon').addClass('hidden');
    });
  }
};

$(document).ready(function() {
  TagFollowings.initialize();
});
