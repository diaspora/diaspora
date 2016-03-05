app.views.SearchBase = app.views.Base.extend({
  initialize: function(options) {
    this.ignoreDiasporaIds = [];
    this.typeaheadInput = options.typeaheadInput;
    this.setupBloodhound(options);
    if(options.customSearch) { this.setupCustomSearch(); }
    this.setupTypeahead();
    // TODO: Remove this as soon as corejavascript/typeahead.js has its first release
    this.setupMouseSelectionEvents();
    if(options.autoselect) { this.setupAutoselect(); }
  },

  bloodhoundTokenizer: function(str) {
    if(typeof str !== "string") { return []; }
    return str.split(/[\s\.:,;\?\!#@\-_\[\]\{\}\(\)]+/).filter(function(s) { return s !== ""; });
  },

  setupBloodhound: function(options) {
    var bloodhoundOptions = {
      datumTokenizer: function(datum) {
        var nameTokens = this.bloodhoundTokenizer(datum.name);
        var handleTokens = datum.handle ? this.bloodhoundTokenizer(datum.handle) : [];
        return nameTokens.concat(handleTokens);
      }.bind(this),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      prefetch: {
        url: "/contacts.json",
        transform: this.transformBloodhoundResponse,
        cache: false
      },
      sufficient: 5
    };

    // Allow bloodhound to look for remote results if there is a route given in the options
    if(options.remoteRoute) {
      bloodhoundOptions.remote = {
        url: options.remoteRoute + ".json?q=%QUERY",
        wildcard: "%QUERY",
        transform: this.transformBloodhoundResponse
      };
    }

    this.bloodhound = new Bloodhound(bloodhoundOptions);
  },

  setupCustomSearch: function() {
    var self = this;
    this.bloodhound.customSearch = function(query, sync, async) {
      var _sync = function(datums) {
        var results = datums.filter(function(datum) {
          return datum.handle !== undefined && self.ignoreDiasporaIds.indexOf(datum.handle) === -1;
        });
        sync(results);
      };

      self.bloodhound.search(query, _sync, async);
    };
  },

  setupTypeahead: function() {
    this.typeaheadInput.typeahead({
      hint: false,
      highlight: true,
      minLength: 2
    },
    {
      name: "search",
      display: "name",
      limit: 5,
      source: this.bloodhound.customSearch !== undefined ? this.bloodhound.customSearch : this.bloodhound,
      templates: {
        /* jshint camelcase: false */
        suggestion: HandlebarsTemplates.search_suggestion_tpl
        /* jshint camelcase: true */
      }
    });
  },

  transformBloodhoundResponse: function(response) {
    return response.map(function(data) {
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
  },

  _deselectAllSuggestions: function() {
    this.$(".tt-suggestion").removeClass("tt-cursor");
  },

  _selectSuggestion: function(suggestion) {
    this._deselectAllSuggestions();
    suggestion.addClass("tt-cursor");
  },

  // TODO: Remove this as soon as corejavascript/typeahead.js has its first release
  setupMouseSelectionEvents: function() {
    var self = this,
        selectSuggestion = function(e) { self._selectSuggestion($(e.target).closest(".tt-suggestion")); },
        deselectAllSuggestions = function() { self._deselectAllSuggestions(); };

    this.typeaheadInput.on("typeahead:render", function() {
      self.$(".tt-menu .tt-suggestion").off("mouseover").on("mouseover", selectSuggestion);
      self.$(".tt-menu .tt-suggestion *").off("mouseover").on("mouseover", selectSuggestion);
      self.$(".tt-menu .tt-suggestion").off("mouseleave").on("mouseleave", deselectAllSuggestions);
    });
  },

  // Selects the first result when the result dropdown opens
  setupAutoselect: function() {
    var self = this;
    this.typeaheadInput.on("typeahead:render", function() {
      self._selectSuggestion(self.$(".tt-menu .tt-suggestion").first());
    });
  },

  ignorePersonForSuggestions: function(person) {
    if(person.handle) { this.ignoreDiasporaIds.push(person.handle); }
  },
});
