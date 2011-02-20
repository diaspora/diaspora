$(document).ready(function() {
  var scrolled = 0;

  $('#main_stream').infinitescroll({
    navSelector  : ".pagination",
                   // selector for the paged navigation (it will be hidden)
    nextSelector : ".pagination a.next_page",
                   // selector for the NEXT link (to page 2)
    itemSelector : "#main_stream .stream_element",
                   // selector for all items you'll retrieve
    bufferPx: 300,
    debug: false,
    donetext: "no more.",
    loadingText: "",
    loadingImg: '/images/ajax-loader.gif'
  }, function() {
    scrolled++;

    if(scrolled > 2) {
       (scrolled === 3) && $(window).unbind('.infscr');

       $("a.paginate")
        .detach()
        .appendTo("#main_stream")
        .css("display", "block");
    }
    Diaspora.widgets.timeago.updateTimeAgo();
  });



  $("a.paginate").live("click", function() {
    $(this).css("display", "none");

    $(document).trigger("retrieve.infscr");
  })
  .css("display", "none");
});

