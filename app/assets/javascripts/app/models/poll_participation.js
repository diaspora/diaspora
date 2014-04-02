app.models.PollParticipation = Backbone.Model.extend({
  urlRoot: function(){
    return '/posts/' + this.get('post_id') + "/poll_participations";
  }
});
