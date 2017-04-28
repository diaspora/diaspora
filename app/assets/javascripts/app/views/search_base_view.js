app.views.SearchBase = app.views.Base.extend({
  initialize: function(options) {
    this.ignoreDiasporaIds = [];
    this.typeaheadInput = options.typeaheadInput;
    this.suggestionLink = options.suggestionLink || false;
    this.setupBloodhound(options);
    if(options.customSearch) { this.setupCustomSearch(); }
    this.setupTypeahead();
    if(options.autoselect) { this.setupAutoselect(); }
    this.setupTypeaheadAvatarFallback();
  },

  bloodhoundTokenizer: function(str) {
    if(typeof str !== "string") { return []; }
    return str.split(/[\s\.:,;\?\!#@\-_\[\]\{\}\(\)]+/).filter(function(s) { return s !== ""; });
  },

  setupBloodhound: function(options) {
    var bloodhoundOptions = {
      datumTokenizer: function(datum) {
        // hashtags
        if(typeof datum.handle === "undefined") { return [datum.name]; }
        // people
        if(datum.name === datum.handle) { return [datum.handle]; }
        return this.bloodhoundTokenizer(datum.name).concat(datum.handle);
      }.bind(this),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      sufficient: 5
    };

    // Allow bloodhound to look for remote results if there is a route given in the options
    if (options.remoteRoute && options.remoteRoute.url) {
      var extraParameters = "";
      if (options.remoteRoute.extraParameters) {
        extraParameters += "&" + options.remoteRoute.extraParameters;
      }
      bloodhoundOptions.remote = {
        url: options.remoteRoute.url + ".json?q=%QUERY" + extraParameters,
        wildcard: "%QUERY",
        transform: this.transformBloodhoundResponse.bind(this)
      };
    }

    this.bloodhound = new Bloodhound(bloodhoundOptions);
  },

  setupCustomSearch: function() {
    var self = this;
    this.bloodhound.customSearch = function(query, sync, async) {
      var _async = function(datums) {
        var results = datums.filter(function(datum) {
          return datum.handle !== undefined && self.ignoreDiasporaIds.indexOf(datum.handle) === -1;
        });
        async(results);
      };

      self.bloodhound.search(query, sync, _async);
    };
  },

  setupTypeahead: function() {
    this.typeaheadInput.typeahead({
      hint: false,
      highlight: true,
      minLength: 2
    }, {
      async: true,
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
        data.link = this.suggestionLink;
        return data;
      }

      // hashtag
      return {
        hashtag: true,
        name: data.name,
        url: Routes.tag(data.name.substring(1))
      };
    }.bind(this));
  },

  _deselectAllSuggestions: function() {
    this.$(".tt-suggestion").removeClass("tt-cursor");
  },

  _selectSuggestion: function(suggestion) {
    this._deselectAllSuggestions();
    suggestion.addClass("tt-cursor");
  },

  // Selects the first result when the result dropdown opens
  setupAutoselect: function() {
    var self = this;
    this.typeaheadInput.on("typeahead:render", function() {
      self._selectSuggestion(self.$(".tt-menu .tt-suggestion").first());
    });
  },

  setupTypeaheadAvatarFallback: function() {
    this.typeaheadInput.on("typeahead:render", function() {
      this.setupAvatarFallback(this.$el);
    }.bind(this));
  },

  ignorePersonForSuggestions: function(person) {
    if(person.handle) { this.ignoreDiasporaIds.push(person.handle); }
  }
});
