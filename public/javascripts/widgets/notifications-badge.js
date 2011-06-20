(function() {
  $("#notification_badge a").live("click", function(event){
    event.preventDefault();
    $.getJSON("/notifications", function(hash) {
      $("#notifications_overlay").show();
      var notificationsElement =  $("#notifications_overlay .notifications");
      var dayElementTemplate = $("#notifications_overlay .day_group").clone();
      dayElementTemplate.find(".notifications_for_day").empty();
      var streamElementTemplate = $("#notifications_overlay .stream_element").clone();
      notificationsElement.empty();
      $.each(hash["group_days"], function(day){
        var dayElement = dayElementTemplate.clone();
        var dayParts = day.split(" ");
        dayElement.find(".month").text(dayParts[0])
        dayElement.find(".day").text(dayParts[1])
        var notificationsForDay = hash["group_days"][day],
          notificationsForDayElement = dayElement.find('.notifications_for_day');
          
        $.each(notificationsForDay, function(i, notificationHash) {
          $.each(notificationHash, function(notificationType, notification) {
            var actor = notification.actors[0];
            var streamElement = streamElementTemplate.clone().appendTo(notificationsForDayElement);
            streamElement.find(".actor")
              .text(actor.name)
              .attr("href", notification.actors[0]["url"]);
            streamElement.find('time').text(notification["created_at"]);
          });
        });
        notificationsElement.append(dayElement);
      });
    });
  });
  
})();