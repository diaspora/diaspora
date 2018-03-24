// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

var List = {
  runDelayedSearch: function( searchTerm ) {
    $.getJSON('/people/refresh_search',
      { q: searchTerm },
      List.handleSearchRefresh
    );
  },

  handleSearchRefresh: function( data ) {
    var streamEl = $("#people-stream.stream");
    var string = data.search_html || $("<p>", {
        text : Diaspora.I18n.t("people.not_found")
      });

    streamEl.html(string);

    if (data.contacts) {
      var contacts = new app.collections.Contacts(data.contacts);
      $(".aspect-membership-dropdown.placeholder").each(function() {
        var personId = $(this).data("personId");
        var view = new app.views.AspectMembership({person: contacts.findWhere({"person_id": personId}).person});
        $(this).html(view.render().$el);
      });
    }
  },

  startSearchDelay: function (theSearch) {
    setTimeout( "List.runDelayedSearch('" + theSearch + "')", 10000);
  }
};

$(document).ready(function() {
  if (gon.preloads.background_query) {
    List.startSearchDelay(gon.preloads.background_query);
  }
});
// @license-end
