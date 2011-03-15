/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var FriendFinder = {

  initialize: function() {
    $('.contact_list .button').click(function(){
      $this = $(this);
      var uid = $this.parents('li').attr("uid");
      $this.parents('ul').children("#options_"+uid).slideToggle(function(){
        if($this.text() == 'Done'){
          $this.text($this.attr('old-text'));
        } else {
          $this.attr('old-text', $this.text());
          $this.text('Done');
        }
        $(this).toggleClass('hidden');
      });
    });
  }
};

$(document).ready(FriendFinder.initialize);
