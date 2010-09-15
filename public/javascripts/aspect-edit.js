/*   Copyright 2010 Diaspora Inc.
 *
 *   This file is part of Diaspora.
 *
 *   Diaspora is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Diaspora is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
 */


$('#move_friends_link').live( 'click', function(){
  $.post('/aspects/move_friends',
    { 'moves' : $('#aspect_list').data() },
    function(){ $('#aspect_title').html("Groups edited successfully!");});

  $(".person").css('background-color','none');
  $('#aspect_list').removeData();
  $(".person").attr('from_aspect_id', function(){return $(this).parent().attr('id')})

});

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
          data: {"accept" : true  , "aspect_id" : $(this)[0].id }
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
