/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
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


$(".comment_submit").live('click', function(evt){
  $(this).closest("form").children("p .comment_box").attr("rows", 1);
});

$(".reshare_button").live("click", function(e){
  e.preventDefault();
  var button = $(this);
  button.parent(".reshare_pane").children(".reshare_box").show();
  button.addClass("active");
});

