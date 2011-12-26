app.views.StatusMessage = app.views.StreamObject.extend({
  template_name : "#status-message-template"
});

app.views.Reshare = app.views.StreamObject.extend({
  template_name : "#reshare-template"
});

app.views.ActivityStreams__Photo = app.views.StreamObject.extend({
  template_name : "#activity-streams-photo-template"
});
