var Search = {
  source : '/people.json',

  selector : '#global_search input#q',
  formatItem: function(row){
    if(row['search']) {
      return $.mustache(Diaspora.widgets.i18n.t('search_for'), { name: row['name'] });
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
    results.push(Search.searchLinkli());
    return results;
  },
  selectItemCallback :  function(event, data, formatted) {
    if (data['id'] !== undefined) { // actual result
      $(Search.selector).val(formatted);
      window.location = data['url'];
    } else { //use form val to eliminate timing issue
      window.location = '/people?q='+$(Search.selector).val();
    }
  },
  options : function(){return {
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
    var searchTerm = $(Search.selector).val();
    return {
      data : {
        'search' : true,
        'url' : '/people?q=' + searchTerm,
        'name' : searchTerm
      },
      value : searchTerm
    };
  },

  initialize : function() {
    $(Search.selector).autocomplete(Search.source, Search.options());
  }
}

$(document).ready(function(){
  Search.initialize();
});
