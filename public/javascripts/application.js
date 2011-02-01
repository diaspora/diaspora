$(document).ready(function() {
  $('#main_stream').infinitescroll({
    navSelector  : ".pagination",
                   // selector for the paged navigation (it will be hidden)
    nextSelector : ".pagination a.next_page",
                   // selector for the NEXT link (to page 2)
    itemSelector : "#main_stream .stream_element",
                   // selector for all items you'll retrieve
    bufferPx: 300,
    debug: true,
    donetext: "no more.",
    loadingText: "",
    loadingImg: '/images/ajax-loader.gif'
  }, function() {
    $("a.paginate")
      .detach()
      .appendTo("#main_stream")
      .css("display", "block");
    Diaspora.widgets.timeago.updateTimeAgo();
  });

  $(window).unbind('.infscr');

  $("a.paginate").live("click", function() {
    $(this).css("display", "none");

    $(document).trigger("retrieve.infscr");
  });

  $('a').live('tap',function(){
    $(this).addClass('tapped');
  })
});

