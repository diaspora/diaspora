$(document).ready(function() {

  InfiniteScroll.initialize();

  $("a.paginate").live("click", function() {
    $(this).css("display", "none");

    $(document).trigger("retrieve.infscr");
  })
  .css("display", "none");
});

