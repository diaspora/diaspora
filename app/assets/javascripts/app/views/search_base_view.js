app.views.SearchBase = app.views.Base.extend({
  completeSetup: function(typeaheadElement){
    this.typeaheadElement = $(typeaheadElement);
    this.setupBloodhound();
    this.setupTypeahead();
    this.bindSelectionEvents();
    this.resultsTofilter = [];
  },

  setupBloodhound: function() {
    var self = this;
    var bloodhoundConf = {
      datumTokenizer: function(datum) {
        var nameTokens = Bloodhound.tokenizers.nonword(datum.name);
        var handleTokens = datum.handle ? Bloodhound.tokenizers.nonword(datum.name) : [];
        return nameTokens.concat(handleTokens);
      },
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      prefetch: {
        url: "/contacts.json",
        transform: this.transformBloodhoundResponse,
        cache: false
      },
      sufficient: 5
    };

    // The publisher does not define an additionnal source for searchin
    // This prevents tests from failing when this additionnal source isn't set
    if(this.searchFormAction !== undefined){
      bloodhoundConf.remote = {
        url: this.searchFormAction + ".json?q=%QUERY",
        wildcard: "%QUERY",
        transform: this.transformBloodhoundResponse
      };
    }

    this.bloodhound = new Bloodhound(bloodhoundConf);

    /**
     * Custom searching function that let us filter contacts from prefetched Bloodhound results.
     */
    this.bloodhound.customSearch = function(query, sync, async){
      var filterResults = function(datums){
        return _.filter(datums, function(result){
          if(result.handle){
            return !_.contains(self.resultsTofilter, result.handle);
          }
        });
      };

      var _sync = function(datums){
        var results = filterResults(datums);
        sync(results);
      };

      self.bloodhound.search(query, _sync, async);
    };
  },

  setupTypeahead: function() {
    this.typeaheadElement.typeahead({
          hint: false,
          highlight: true,
          minLength: 2
        },
        {
          name: "search",
          display: "name",
          limit: 5,
          source: this.bloodhound.customSearch,
          templates: {
            /* jshint camelcase: false */
            suggestion: HandlebarsTemplates.search_suggestion_tpl
            /* jshint camelcase: true */
          }
        });
  },

  transformBloodhoundResponse: function(response) {
    return response.map(function(data){
      // person
      if(data.handle){
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

  /**
   * This bind events to highlight a result when overing it
   */
  bindSelectionEvents: function(){
    var self = this;
    var onover = function(suggestion){
      return function(){
        self.select(suggestion);
      };
    };

    this.typeaheadElement.on("typeahead:render", function(){
      self.$(".tt-menu *").off("mouseover");
      self.$(".tt-menu .tt-suggestion").each(function(){
        var $suggestion = $(this);
        $suggestion.on("mouseover", onover($suggestion));
        $suggestion.find("*").on("mouseover", onover($suggestion));
      });
    });
  },

  /**
   * This function lets us filter contacts from Bloodhound's responses
   * It is used by app.views.PublisherMention to filter already mentionned
   * people in post. Does not filter tags from results.
   * @param person a JSON object of form { handle: <diaspora handle>, ... } representing the filtered contact
   */
  addToFilteredResults: function(person){
    if(person.handle){
      this.resultsTofilter.push(person.handle);
    }
  },

  clearFilteredResults: function(){
    this.resultsTofilter.length = 0;
  },

  getSelected: function(){
    return this.$el.find(".tt-cursor");
  },

  select: function(el){
    this.getSelected().removeClass("tt-cursor");
    $(el).addClass("tt-cursor");
  }
});
