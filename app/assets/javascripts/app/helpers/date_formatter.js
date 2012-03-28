(function(){
  var dateFormatter = function dateFormatter() {

  };

  dateFormatter.parse = function(date_string) {
    var timestamp = new Date(date_string).getTime();

    if (isNaN(timestamp)) {
      timestamp = dateFormatter.parseISO8601UTC(date_string);
    }

    return timestamp;
  },

  dateFormatter.parseISO8601UTC = function(date_string) {
    var iso8601_utc_pattern = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(.(\d{3}))?Z$/;
    var time_components = date_string.match(iso8601_utc_pattern);
    var timestamp = 0;

    if (time_components != null) {
      if (time_components[8] == undefined) {
        time_components[8] = 0;
      }

      timestamp = Date.UTC(time_components[1], time_components[2] - 1, time_components[3],
                           time_components[4], time_components[5], time_components[6],
                           time_components[8]);
    }

    return timestamp;
  },

  app.helpers.dateFormatter = dateFormatter;
})();
