// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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
// @license-end
