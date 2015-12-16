// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.views.Search = app.views.Base.extend({
  initialize: function(){
    this.searchFormAction = this.$el.attr('action');
    this.searchInput = this.$('input[type="search"]');
    this.searchInputName = this.$('input[type="search"]').attr('name');
    this.searchInputHandle = this.$('input[type="search"]').attr('handle');
    this.options = {
      cacheLength: 15,
      delay: 800,
      extraParams: {limit: 4},
      formatItem: this.formatItem,
      formatResult: this.formatResult,
      max: 5,
      minChars: 2,
      onSelect: this.selectItemCallback,
      parse: this.parse,
      scroll: false,
      context: this
    };

    var self = this;
    this.searchInput.autocomplete(self.searchFormAction + '.json',
        $.extend(self.options, { element: self.searchInput }));
  },

  formatItem: function(row){
    if(typeof row.search !== 'undefined') { return Diaspora.I18n.t('search_for', row); }
    else {
      var item = '';
      if (row.avatar) { item += '<img src="' + row.avatar + '" class="avatar"/>'; }
      item += row.name;
      if (row.handle) { item += '<div class="search_handle">' + row.handle + '</div>'; }
      return item;
    }
  },

  formatResult: function(row){ return Handlebars.Utils.escapeExpression(row.name); },

  parse: function(data) {
    var self = this.context;

    var results =  data.map(function(person){
      person.name = self.formatResult(person);
      return {data : person, value : person.name};
    });

    results.push({
      data: {
        name: self.searchInput.val(),
        url: self.searchFormAction + '?' + self.searchInputName + '=' + self.searchInput.val(),
        search: true
      },
      value: self.searchInput.val()
    });

    return results;
  },

  selectItemCallback: function(evt, data, formatted){
    var self = this.context;

    if(data.search === true){
      window.location = self.searchFormAction + '?' + self.searchInputName + '=' + data.name;
    }
    else{ // The actual result
      self.options.element.val(formatted);
      window.location = data.url ? data.url : '/tags/' + data.name.substring(1);
    }
  }
});
// @license-ends
