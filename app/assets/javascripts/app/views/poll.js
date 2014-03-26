app.views.Poll = app.views.Base.extend({
  templateName : "poll",

  events : {
    "click .submit" : "vote",
    "click .toggle_result" : "toggleResult"
  },

  initialize : function(options) {
    this.poll = this.model.attributes.poll;
    this.progressBarFactor = 3;
  },

  postRenderTemplate : function() {
    if(this.poll) {
      this.setProgressBar();
      this.hideResult();
    }
  },

  hideResult : function() {
    if(!this.model.attributes.already_participated_in_poll) {
      this.$('.poll_result').hide();
    }
  },

  setProgressBar : function() {
    var answers = this.poll.poll_answers;
    for(index = 0; index < answers.length; ++index) {
      var percentage = 0;
      if(this.poll.participation_count != 0) {
        percentage = answers[index].vote_count / this.poll.participation_count * 100;
      }
      var progressBar = this.$(".poll_progress_bar[data-answerid="+answers[index].id+"]");
      progressBar.parents().eq(1).find(".percentage").html(" - " + percentage + "%");
      var width = percentage * this.progressBarFactor;
      progressBar.css("width", width + "px");
    }
  },

  toggleResult : function(e) {
    $('.poll_result').toggle();
    return false;
  },

  refreshResult : function(answerId) {
    this.updateCounter(answerId);
    this.setProgressBar();
  },

  updateCounter : function(answerId) {
    this.poll.participation_count++;
    this.$('.poll_statistic').html(Diaspora.I18n.t("poll.count", {"votes" : this.poll.participation_count}));
    var answers = this.poll.poll_answers;
    for(index = 0; index < answers.length; ++index) {
      if(answers[index].id == answerId) {
        answers[index].vote_count++;
        return;
      }
    }
  },

  vote : function(evt){
    var result = parseInt($(evt.target).parent().find("input[name=vote]:checked").val());
    var pollParticipation = new app.models.PollParticipation();
    var parent = this;
    pollParticipation.save({
      "poll_answer_id" : result,
      "poll_id" : this.poll.poll_id,
    },{
      url : "/posts/"+this.poll.post_id+"/poll_participations",
      success : function(model, response) {
        parent.$('.poll_form form').remove();
        parent.$('.toggle_result_wrapper').remove();
        parent.$('.poll_result').show();
        parent.refreshResult(result);
      }
    });
    return false;
  }

});