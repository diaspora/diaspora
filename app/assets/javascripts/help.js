$(document).ready(function() {
  app.help = new app.views.Help();
  $("#help").prepend(app.help.el);
  app.help.render();
});