var Search = {
  selector : '.search_form input[type="search"]',
  formatItem: function(row){
    if(row['search']) {
      var data = { name: this.element.val() }
      return Diaspora.widgets.i18n.t('search_for', data);
    } else {
      return "<img src='"+ row['avatar'] +"' class='avatar'/>" + row['name'];
    }
  },
  formatResult: function(row){
     return row['name'];
   },
  parse : function(data) {
    results =  data.map(function(person){
      return {data : person, value : person['name']}
    });
    results.push(Search.searchLinkli.apply(this));
    return results;
  },
  selectItemCallback :  function(element, data, formatted) {
    if (data['search'] === true) { // The placeholder "search for" result
      window.location = this.element.parents("form").attr("action") + '?' + this.element.attr("name") +'=' + data['name'];
    } else { // The actual result
      element.val(formatted);
      window.location = data['url'];
    }
  },
  options : function(element){return {
      element: element,
      minChars : 2,
      onSelect: Search.selectItemCallback,
      max : 5,
      scroll : false,
      delay : 100,
      cacheLength : 15,
      extraParams : {limit : 4},
      formatItem : Search.formatItem,
      formatResult : Search.formatResult,
      parse : Search.parse
  };},

  searchLinkli : function() {
    var searchTerm = this.element.val();
    if(searchTerm[0] === "#"){
      searchTerm = searchTerm.slice(1);
    }
    return {
      data : {
        'search' : true,
        'url' : this.element.parents("form").attr("action") + '?' + this.element.attr("name") +'=' + searchTerm,
        'name' : searchTerm
      },
      value : searchTerm
    };
  },

  initialize : function() {
    $(Search.selector).each(function(index, element){
      var $element = $(element);
      var action = $element.parents("form").attr("action") + '.json';
      $element.autocomplete(action, Search.options($element));
    });
  }
}

$(document).ready(function(){
  Search.initialize();
});
