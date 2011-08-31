(function() {
  var Search = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, searchForm) {
      $.extend(self, {
        searchForm: searchForm,
        searchFormAction: searchForm.attr("action"),
        searchInput: searchForm.find("input[type='search']"),
        searchInputName: searchForm.find("input[type='search']").attr("name"),
        options: {
          cacheLength : 15,
          delay : 100,
          extraParams : {limit : 4},
          formatItem : self.formatItem,
          formatResult : self.formatResult,
          max : 5,
          minChars : 2,
          onSelect: self.selectItemCallback,
          parse : self.parse,
          scroll : false
        }
      });

      self.searchInput.autocomplete(self.searchFormAction + ".json", $.extend(self.options, {
        element: self.searchInput
      }));
    });

    this.formatItem = function(row) {
      if (typeof row.search !== "undefined") {
        return Diaspora.I18n.t("search_for", row);
      } else {
        return "<img src='"+ row.avatar +"' class='avatar'/>" + row.name;
      }
    };

    this.formatResult = function(row) {
      return row.name;
    };

    this.parse = function(data) {
      var results =  data.map(function(person){
        return {data : person, value : person['name']}
      });

      results.push({
        data: {
          name: self.searchInput.val(),
          url: self.searchFormAction + "?" + self.searchInputName + "=" + self.searchInput.val(),
          search: true
        },
        value: self.searchInput.val()
      });

      return results;
    };

    this.selectItemCallback = function(evt, data, formatted) {
      if (data['search'] === true) { // The placeholder "search for" result
        window.location = self.searchFormAction + '?' + self.searchInputName + '=' + data['name'];
      } else { // The actual result
        self.options.element.val(formatted);
        window.location = data['url'];
      }
    };
  };

  Diaspora.Widgets.Search = Search;
})();
