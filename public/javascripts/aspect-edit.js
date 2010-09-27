/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3.  See
*   the COPYRIGHT file.
*/

function decrementRequestsCounter() {
  var $new_requests = $(".new_requests"),
      request_html  = $new_requests.html(),
      old_request_count = request_html.match(/\d+/);

  if( old_request_count == 1 ) {
    $new_requests.html(
      request_html.replace(/ \(\d+\)/,'')
    );
  } else {
    $new_requests.html(
      request_html.replace(/\d+/,old_request_count-1)
    );
  }
}

$(function() {
  // Multiple classes here won't work
  $("ul .person").draggable({
    revert: true
  });

  $("ul .requested_person").draggable({
    revert: true
  });

  $(".aspect ul").droppable({
    hoverClass: 'active',
    drop: function(event, ui) {

      if ($(ui.draggable[0]).hasClass('requested_person')){
        $.ajax({
          type: "DELETE",
          url: "/requests/" + ui.draggable[0].getAttribute('request_id') ,
          data: {"accept" : true  , "aspect_id" : $(this)[0].id },
          success: function(data){
            decrementRequestsCounter();
          }
        });

      };
        var dropzone = $(this)[0];

        if ($(this)[0].id == ui.draggable[0].getAttribute('from_aspect_id')){
          ui.draggable.css('background','none');
        } else {
          ui.draggable.css('background-color','orange');
          $.ajax({
            url: "/aspects/move_friend/",
            data: {"friend_id" : ui.draggable[0].id,
                   "from" : ui.draggable[0].getAttribute('from_aspect_id'),
                   "to" : { "to" : dropzone.id }},
            success: function(data){
              ui.draggable.attr('from_aspect_id', dropzone.id);
              ui.draggable.css('background','none');
            }});

        }
      $(this).closest("ul").append(ui.draggable);
    }
  });

  $(".remove ul").droppable({
    hoverClass: 'active',
    drop: function(event, ui) {

      if ($(ui.draggable[0]).hasClass('requested_person')){
        $.ajax({
          type: "DELETE",
          url: "/requests/" + ui.draggable.attr('request_id'),
          success: function () {
            decrementRequestsCounter();
          }
        });

      } else {
        $.ajax({
          type: "DELETE",
          url: "/people/" + ui.draggable.attr('id'),
          success: function () {
            alert("Removed Friend, proably want an undo countdown.")
          }
        });

      }

      $(ui.draggable[0]).fadeOut('slow'); // ui.draggable.fadeOut('slow')
    }
  });


  $(".aspect h1").live( 'focus', function() {

    var $this = $(this),
        id    = $this.closest("li").children("ul").attr("id"),
        link  = "/aspects/"+ id;

    $this.keypress(function(e) {
      if (e.which == 13) {
        e.preventDefault();
        $this.blur();

        //save changes
        $.ajax({
          type: "PUT",
          url: link,
          data: {"aspect" : {"name" : $this.text() }}
        });
      }
      //update all other aspect links
      $this.keyup(function(e) {
        $("#aspect_nav a[href='"+link+"']").text($this.text());
      });
    });
  });

});
