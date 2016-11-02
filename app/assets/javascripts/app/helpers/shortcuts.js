// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
(function() {
  app.helpers.Shortcuts = function(evtname, fn) {
    var textAcceptingInputTypes = [
      "color",
      "date",
      "datetime",
      "datetime-local",
      "email",
      "month",
      "number",
      "password",
      "range",
      "search",
      "select",
      "text",
      "textarea",
      "time",
      "url",
      "week"
    ];

    $("body").on(evtname, function(event) {
      // make sure that the user is not typing in an input field
      if (textAcceptingInputTypes.indexOf(event.target.type) === -1) {
        fn(event);
      }
    });
  };
})();
// @license-end
