/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */


$(document).ready(function(){
  $("div.public_toggle input").live("click", function(evt){
    $("#publisher_service_icons").toggleClass("dim");
    if($(this).attr('checked') == true){
      $(".question_mark").click();
    };
  });

  if($("textarea#status_message_message").val() != ""){
    $("#publisher").removeClass("closed");
    $("#publisher").find("textarea").focus();
    $("#publisher .options_and_submit").show();
  }

  $("#publisher textarea").live("focus", function(evt){
    $("#publisher .options_and_submit").show();
  });

  $("#publisher textarea").live("click", function(evt){
    $("#publisher").removeClass("closed");
    $("#publisher").find("textarea").focus();
  });
});
