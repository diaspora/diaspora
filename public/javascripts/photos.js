$(document).ready(function(){
  reset_photo_fancybox();

  $("#add_photo_button").fancybox({
    'onClosed'   :   function(){
      if($("#add_photo_button").hasClass("uploading_complete")){
        $("#add_photo_button").removeClass("uploading_complete");
        reset_photo_fancybox();
      }
    }
  });

  $(".image_thumb img").load( function() {
    $(this).fadeIn("slow");
  });

});//end document ready

function reset_photo_fancybox(){
    album_id = $(".album_id")[0].id;
    ajax = $.get("/photos/new?album_id=" + album_id, function(){
      $("#new_photo_pane").html(ajax.responseText)
    });
}

