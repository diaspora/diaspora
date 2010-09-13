$('#move_friends_link').live( 'click', function(){
  $.post('/aspects/move_friends',
    { 'moves' : $('#aspect_list').data() },
    function(){ $('#aspect_title').html("Groups edited successfully!");});

  $(".person").css('background-color','white');
  $('#aspect_list').removeData();
  $(".person").attr('from_aspect_id', function(){return $(this).parent().attr('id')})

});

$(function() {
  $("li .person").draggable({
    revert: true
  });

  $("li .requested_person").draggable({
    revert: true
  });
  
  $(".aspect ul").droppable({
    drop: function(event, ui) {

      if ($(ui.draggable[0]).hasClass('requested_person')){
        $.ajax({
          type: "DELETE",
          url: "/requests/" + ui.draggable[0].getAttribute('request_id') ,
          data: {"accept" : true  , "aspect_id" : $(this)[0].id }
        });
        alert("Sent the ajax, check it out!")
      }else {
        var move = {};
        move[ 'friend_id' ] = ui.draggable[0].id
        move[ 'to' ] = $(this)[0].id;
        move[ 'from' ] = ui.draggable[0].getAttribute('from_aspect_id');
        if (move['to'] == move['from']){
          $('#aspect_list').data( ui.draggable[0].id, []);
          ui.draggable.css('background-color','white');
        } else {
          $('#aspect_list').data( ui.draggable[0].id, move);
          ui.draggable.css('background-color','orange');
        }
        $(this).closest("ul").append(ui.draggable);
      }
    }
  });

  $(".remove ul").droppable({
    drop: function(event, ui) {

      if ($(ui.draggable[0]).hasClass('requested_person')){
        $.ajax({
          type: "DELETE",
          url: "/requests/" + ui.draggable[0].getAttribute('request_id')
        });
        alert("Removed Request, proably want an undo countdown.")
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

$(".aspect h3").live( 'click', function() {

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
      $("a[href='"+link+"']").text($this.text());
    });
  });
});
