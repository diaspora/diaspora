// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.views.Search = app.views.Base.extend({
  events: {
    "focusin #q": "toggleSearchActive",
    "focusout #q": "toggleSearchActive",
    "keypress #q": "inputKeypress",
  },

  initialize: function(){
    this.searchFormAction = this.$el.attr("action");
    this.searchInput = this.$("#q");

    // constructs the suggestion engine
    this.setupBloodhound();
    this.setupTypeahead();
    this.searchInput.on("typeahead:select", this.suggestionSelected);
  },

  setupBloodhound: function() {
    this.bloodhound = new Bloodhound({
      datumTokenizer: function(datum) {
        var nameTokens = Bloodhound.tokenizers.nonword(datum.name);
        var handleTokens = datum.handle ? Bloodhound.tokenizers.nonword(datum.name) : [];
        return nameTokens.concat(handleTokens);
      },
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      remote: {
        url: this.searchFormAction + ".json?q=%QUERY",
        wildcard: "%QUERY",
        transform: this.transformBloodhoundResponse
      },
      prefetch: {
        url: "/contacts.json",
        transform: this.transformBloodhoundResponse,
        cache: false
      },
      sufficient: 5
    });
  },

  setupTypeahead: function() {
    this.searchInput.typeahead({
      hint: false,
      highlight: true,
      minLength: 2
    },
    {
      name: "search",
      display: "name",
      limit: 5,
      source: this.bloodhound,
      templates: {
        /* jshint camelcase: false */
        suggestion: HandlebarsTemplates.search_suggestion_tpl
        /* jshint camelcase: true */
      }
    });
  },

  transformBloodhoundResponse: function(response) {
    var result = response.map(function(data) {
      // person
      if(data.handle) {
        data.person = true;
        return data;
      }

      // hashtag
      return {
        hashtag: true,
        name: data.name,
        url: Routes.tag(data.name.substring(1))
      };
    });

    return result;
  },

  toggleSearchActive: function(evt) {
    // jQuery produces two events for focus/blur (for bubbling)
    // don't rely on which event arrives first, by allowing for both variants
    var isActive = (_.indexOf(["focus","focusin"], evt.type) !== -1);
    $(evt.target).toggleClass("active", isActive);
  },

  suggestionSelected: function(evt, datum) {
    window.location = datum.url;
  },

  inputKeypress: function(evt) {
    if(evt.which === 13 && $(".tt-suggestion.tt-cursor").length === 0) {
      $(evt.target).closest("form").submit();
    }
  }
});
// @license-ends
