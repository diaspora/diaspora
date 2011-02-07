/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

var Mobile = {
  initialize: function() {
    $('#main_stream + .pagination').hide();
    $('a').live('tap',function(){
      $(this).addClass('tapped');
    })
  },

  windowLocation: function(url) {
    window.location = url;
  }
};

$(document).ready(function() {
  Mobile.initialize();
 });

