Diaspora.Pages.ContactsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.infiniteScroll = self.instantiate("InfiniteScroll");
    $('.conversation_button').twipsy({position: 'below'});
  });
};

function runDelayedSearch( searchTerm ) {
  $.ajax({
    dataType: 'json',
    url: '/people/refresh_search',
    data: { q: searchTerm },
    success: handleSearchRefresh
  });
}

function handleSearchRefresh(data) {
  if ( data.search_count > 0 ) {
    $("#people_stream.stream").html( data.search_html );
  } else {
    $("p#not_found").removeClass( 'hidden' );
    $("p#searching").addClass( 'hidden' );
  }
}