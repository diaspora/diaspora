app.views.PublisherEventCreator = app.views.Base.extend({
  templateName: "event_creator",

  postRenderTemplate: function() {
    this.enableDateTimepicker();
    this.trigger("change");
    this.bind("publisher:sync", this.render, this);
  },

  validateEvent: function() {
    var eventValid = true;
    //validateInputs!!!
    return eventValid;
  },

  enableDateTimepicker: function() {
    $(document).ready(function() {
      $(".datepicker").datepicker();
      $("#timepicker").timepicker();
    });
  }
});
