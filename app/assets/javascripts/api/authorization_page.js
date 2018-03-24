$(document).ready(function() {
  $("#js-app-logo").on("error", function() {
    $(this).attr("src", ImagePaths.get("user/default.png"));
  });
});
