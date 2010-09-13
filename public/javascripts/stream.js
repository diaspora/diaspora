/*   Copyright 2010 Diaspora Inc.
 *
 *   This file is part of Diaspora.
 *
 *   Diaspora is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Diaspora is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
 */


$(document).ready(function(){
	$('.comment_set').each(function(index) {
      var $this = $(this);
	    if($this.children().length > 1) {
        var show_comments_toggle = $this.parent().prev().children(".show_post_comments");
        show_comments_toggle.click();
      }
  });
});//end document ready

$("#stream li").live('mouseover',function() {
  $(this).children(".destroy_link").fadeIn(0);
});

$("#stream li").live('mouseout',function() {
  $(this).children(".destroy_link").fadeOut(0);
});

$(".show_post_comments").live('click', function(event) {
  event.preventDefault();

  var $this = $(this);

  if( $this.hasClass( "visible")) {
    $this.html($(this).html().replace("hide", "show"));
    $this.closest("li").children(".content").children(".comments").fadeOut(100);
  } else {
    $this.html($(this).html().replace("show", "hide"));
    $this.closest("li").children(".content").children(".comments").fadeIn(100);
  }
  $(this).toggleClass( "visible" );
});

$(".comment_box").live('focus', function(evt){
  var $this = $(this);
  $this.attr("rows", 2);
  $this.parents("p").parents("form").children("p").children(".comment_submit").fadeIn(200);
});

$(".comment_box").live('blur', function(evt){
  var $this = $(this);
  if( $this.val() == '' ) {
    $this.parents("p").parents("form").children("p").children(".comment_submit").fadeOut(0);
    $this.attr("rows", 1);
  }
});

$(".comment_submit").live('click', function(evt){
  $(this).closest("form").children("p .comment_box").attr("rows", 1);
});

