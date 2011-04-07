var InfiniteScroll = {
  options: {
    navSelector  : "#pagination",
                   // selector for the paged navigation (it will be hidden)
    nextSelector : ".paginate",
                   // selector for the NEXT link (to page 2)
    itemSelector : ".stream_element",
                   // selector for all items you'll retrieve
    pathParse    : function( pathStr, nextPage ){
      var newPath = pathStr.replace("?", "?only_posts=true&");
      return newPath.replace( "page=2", "page=" + nextPage);
    },
    bufferPx: 500,
    debug: false,
    donetext: "no more.",
    loadingText: "",
    loadingImg: '/images/ajax-loader.gif'
  },
  postScrollCallback: function(){},
  initialize: function(){
    $('#main_stream').infinitescroll(InfiniteScroll.options, InfiniteScroll.postScrollCallback);
  }
}
