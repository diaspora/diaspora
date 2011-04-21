$('.stream_element').live('mousedown', function(evt){
  var note = $(this).closest('.stream_element'),
      note_id = note.attr('data-guid'),
      nBadge = $("#notification_badge .badge_count");

  if(note.hasClass('unread') ){
    note.removeClass('unread');
    $.ajax({
      url: 'notifications/' + note_id,
      type: 'PUT'
    });
  }
    if(nBadge.html() !== null) {
    nBadge.html().replace(/\d+/, function(num){
      num = parseInt(num);
      nBadge.html(parseInt(num)-1);
      if(num == 1) {
        nBadge.addClass("hidden");
      }
  });

  }
});

$('a.more').live('click', function(){
  $(this).hide();
  $(this).next('span').removeClass('hidden');
});
