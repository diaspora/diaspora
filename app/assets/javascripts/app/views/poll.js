app.views.Poll = app.views.Base.extend({
  templateName : "poll",

  events : {
    "click .submit" : "vote"
  },

  initialize : function(options) {
    this.poll = this.model.attributes.poll;
    this.progressBarFactor = 3;
    //this.model.bind('remove', this.remove, this);
  },

  postRenderTemplate : function() {
    if(this.poll) {
      this.setProgressBar();
    }
  },

  setProgressBar : function() {
    var answers = this.poll.poll_answers;
    for(index = 0; index < answers.length; ++index) {
      var percentage = 0;
      if(this.poll.participation_count != 0) {
        percentage = answers[index].vote_count / this.poll.participation_count * 100;
      }
      var input = this.$("input[value="+answers[index].id+"]");
      var progressBar = $(input).parent().find(".poll_progress_bar");
      var width = percentage * this.progressBarFactor;
      progressBar.css("width", width + "px");
    }
    //
  },

  vote : function(evt){
    var result = parseInt($(evt.target).parent().find("input[name=vote]:checked").val());
    var pollParticipation = new app.models.PollParticipation();
    pollParticipation.save({
      "poll_answer_id" : result,
      "poll_id" : this.poll.poll_id,
    },{
      url : "/posts/"+this.poll.post_id+"/poll_participations",
      success : function() {
        console.log(success);
        //todo remove radios+input
      }
    });
  }

});