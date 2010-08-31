$('#move_friends_link').live( 'click', 
    function(){
      $.post('/groups/move_friends',
        {'moves' : $('#group_list').data()},
        function(){ $('#group_title').html("Groups edited successfully!");});
      $(".person").css('background-color','white');
      $('#group_list').removeData();
      $(".person").setAttribute('from_group_id', function(){$(this).closest(".group ul").attr('id')})
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
        } else{
          $('#group_list').data( ui.draggable[0].id, move);
          ui.draggable.css('background-color','orange');
        }
        $(this).closest("ul").append(ui.draggable);
      }
		});

    

	});
