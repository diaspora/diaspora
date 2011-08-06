var ApiConsole = {

  prettyPrint: function(obj, indent)
  {
    var result = "";
    if (indent === null) { indent = ""; }

    for (var property in obj)
      {
        var value = obj[property];
        if (typeof value == 'string')
          { value = "'" + value + "'"; }
        else if (typeof value == 'object')
          {
            if (value instanceof Array)
              {
                // Just let JS convert the Array to a string!
                value = "[ " + value + " ]";
              }
              else
                {
                  // Recursive dump
                  // (replace "  " by "\t" or something else if you prefer)
                  var od = ApiConsole.prettyPrint(value, indent + "  ");
                  // If you like { on the same line as the key
                  //value = "{\n" + od + "\n" + indent + "}";
                  // If you prefer { and } to be aligned
                  value = "\n" + indent + "{\n" + od + "\n" + indent + "}";
                }
          }
          result += indent + "'" + property + "' : " + value + ",\n";
      }
      return result.replace(/,\n$/, "");
  },
  init: function(field, query_box, button){
    this.field = $(field);
    this.query = $(query_box);
    this.button = $(button);


    this.button.click(function(){
      $.getJSON(ApiConsole.query.val(), function(data){
        var json = ApiConsole.prettyPrint(data, '');
        console.dir(json);
        ApiConsole.field.html(json);
      });
    });
  }
};

$(document).ready(function(){

  ApiConsole.init('#resp', 'input[name=api]', '#api_submit:input');
});
