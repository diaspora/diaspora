$('#move_friends_link').live( 'click', function(){
  $.post('/groups/move_friends',
    { 'moves' : $('#group_list').data() },
    function(){ $('#group_title').html("Groups edited successfully!");});

  $(".person").css('background-color','white');
  $('#group_list').removeData();
  $(".person").attr('from_group_id', function(){return $(this).parent().attr('id')})

});

$(function() {
  $("li .person").draggable({
    revert: true
  });
  
  $(".group ul").droppable({
    drop: function(event, ui) {
      var move = {};
      move[ 'friend_id' ] = ui.draggable[0].id
      move[ 'to' ] = $(this)[0].id;
      move[ 'from' ] = ui.draggable[0].getAttribute('from_group_id');
      if (move['to'] == move['from']){
        $('#group_list').data( ui.draggable[0].id, []);
        ui.draggable.css('background-color','white');
      } else {
        $('#group_list').data( ui.draggable[0].id, move);
        ui.draggable.css('background-color','orange');
      }
      $(this).closest("ul").append(ui.draggable);
    }
  });
});

$(".group h3").live( 'click', function() {

  var $this = $(this);
  var id    = $this.closest("li").children("ul").attr("id");
  var link  = "/groups/"+ id;

  $this.keypress(function(e) {
    if (e.which == 13) {
      e.preventDefault();
      $this.blur();

      //save changes
      $.ajax({
        type: "PUT",
        url: link,
        data: {"group" : {"name" : $this.text() }}
      });
    }
    //update all other group links
    $this.keyup(function(e) {
      $("a[href='"+link+"']").text($this.text());
    });
  });
});
