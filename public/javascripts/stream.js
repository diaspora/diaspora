/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3.  See
*   the COPYRIGHT file.
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

$(".show_post_comments").live('click', function(event) {
  event.preventDefault();

  var $this = $(this);

  if( $this.hasClass( "visible")) {
    $this.html($(this).html().replace("hide", "show"));
    $this.closest("li").children(".content").children(".comments").slideUp(150);
  } else {
    $this.html($(this).html().replace("show", "hide"));
    $this.closest("li").children(".content").children(".comments").slideDown(150);
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

