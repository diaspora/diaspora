/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var FriendFinder = {

  initialize: function() {
    alert("party time");
    $('.contact_list .button').click(function(){
      $this = $(this);
      var uid = $this.parent('li').attr("uid");
      alert(uid);
      $this.closest("options_"+uid).toggleClass("hidden").slideDown('slow', function(){});
    });
  }
};

$(document).ready(FriendFinder.initialize);
