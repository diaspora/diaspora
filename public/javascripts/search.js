var Search = {
  formatItem: function(row){
      return "<img src='"+"images/user/default.png"+"' class='avatar'/>" + row['name'];
  },
  formatResult: function(row){
     return row['name'];
   },
  parse : function(data) {
    return data.map(function(person){
      return {data : person, value : person['name']}
    });
  }
}

$(document).ready(function() {
  $('#global_search input').autocomplete('/people.json',
    {
      minChars : 3,
      max : 8,
      autoFill : true,
      formatItem : Search.formatItem,
      formatResult : Search.formatResult,
      parse : Search.parse
  });
});
//$(":text, textarea").result(findValueCallback).next().click(function() {		$(this).prev().search();	});

