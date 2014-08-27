var List = {
  runDelayedSearch: function( searchTerm ) {
    $.getJSON('/people/refresh_search',
      { q: searchTerm },
      List.handleSearchRefresh
    );
  },

  handleSearchRefresh: function( data ) {
    var streamEl = $("#people_stream.stream");
    var string = data.search_html || $("<p>", {
        text : Diaspora.I18n.t("people.not_found")
      });

    streamEl.html(string);
  },

  startSearchDelay: function (theSearch) {
    setTimeout( "List.runDelayedSearch('" + theSearch + "')", 10000);
  }
};
