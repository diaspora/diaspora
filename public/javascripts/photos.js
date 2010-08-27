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

$("#photo_image").html5_upload({
  // WE INSERT ALBUM_ID PARAM HERE
  url: "/photos?album_id="+$(".album_id")[0].id,   
  sendBoundary: window.FormData || $.browser.mozilla,
  setName: function(text) {
    $("#progress_report_name").text(text);
  },
  onFinish: function(event, total){
    $("#add_photo_button").html( "Add Photos" );
    $("#add_photo_loader").fadeOut(400);

    $("#photo_title_status").text("Done!");
    $("#progress_report").html("Good job me!");

    $("#add_photo_button").addClass("uploading_complete");
   },
  onStart: function(event, total){
    $("#add_photo_button").html( "Uploading Photos" );
    $("#add_photo_loader").fadeIn(400);

    $("form.new_photo").fadeOut(0);
    $("#progress_report").fadeIn(0);
    $("#photo_title_status").text("Uploading...");
    return true;
  }
});
