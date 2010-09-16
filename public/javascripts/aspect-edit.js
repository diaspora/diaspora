/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3.  See
*   the COPYRIGHT file.
*/


$('#move_friends_link').live( 'click', function(){
  $.post('/aspects/move_friends',
    { 'moves' : $('#aspect_list').data() },
    function(){ $('#aspect_title').html("Groups edited successfully!");});

  $(".person").css('background-color','none');
  $('#aspect_list').removeData();
  $(".person").attr('from_aspect_id', function(){return $(this).parent().attr('id')})

});

function decrementRequestsCounter(){
  var old_request_count = $(".new_requests").html().match(/\d+/);

  if( old_request_count == 1 ) {
    $(".new_requests").html(
      $(".new_requests").html().replace(/ \(\d+\)/,''));

  } else {
    $(".new_requests").html(
      $(".new_requests").html().replace(/\d+/,old_request_count-1));
  }

}

$(function() {
  $("ul .person").draggable({
    revert: true
  });

  $("ul .requested_person").draggable({
    revert: true
  });
  
  $(".aspect ul").droppable({
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

      }else {
        var move = {};
        move[ 'friend_id' ] = ui.draggable[0].id
        move[ 'to' ] = $(this)[0].id;
        move[ 'from' ] = ui.draggable[0].getAttribute('from_aspect_id');
        if (move['to'] == move['from']){
          $('#aspect_list').data( ui.draggable[0].id, []);
          ui.draggable.css('background-color','#eee');
        } else {
          $('#aspect_list').data( ui.draggable[0].id, move);
          ui.draggable.css('background-color','orange');
        }
      }
      $(this).closest("ul").append(ui.draggable);
    }
  });

  $(".remove ul").droppable({
    drop: function(event, ui) {

      if ($(ui.draggable[0]).hasClass('requested_person')){
        $.ajax({
          type: "DELETE",
          url: "/requests/" + ui.draggable[0].getAttribute('request_id')
        });
        decrementRequestsCounter();
        $(ui.draggable[0]).fadeOut('slow')
      }else{
        $.ajax({
          type: "DELETE",
          url: "/people/" + ui.draggable[0].id
        });
        alert("Removed Friend, proably want an undo countdown.")
        $(ui.draggable[0]).fadeOut('slow')

      }
    }
  });
});

$(".aspect h1").live( 'click', function() {

  var $this = $(this);
  var id    = $this.closest("li").children("ul").attr("id");
  var link  = "/aspects/"+ id;

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
