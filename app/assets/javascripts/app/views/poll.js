app.views.Poll = app.views.Base.extend({
  templateName : "poll",

  events : {
    "click .submit" : "vote",
    "click .toggle_result" : "toggleResult"
  },

  initialize : function(options) {
    this.poll = this.model.attributes.poll;
    this.progressBarFactor = 3;
    this.toggleMode = 0;
  },

  postRenderTemplate : function() {
    if(this.poll) {
      this.setProgressBar();
    }
  },

  removeForm : function() {
      var cnt = this.$("form").contents();
      this.$("form").replaceWith(cnt);
      this.$('input').remove();
      this.$('submit').remove();
      this.$('.toggle_result_wrapper').remove();
  },

  setProgressBar : function() {
    var answers = this.poll.poll_answers;
    for(index = 0; index < answers.length; ++index) {
      var percentage = 0;
      if(this.poll.participation_count != 0) {
        percentage = answers[index].vote_count / this.poll.participation_count * 100;
      }
      var progressBar = this.$(".poll_progress_bar[data-answerid="+answers[index].id+"]");
      progressBar.parent().next().html(" - " + percentage + "%");
      var width = percentage * this.progressBarFactor;
      progressBar.css("width", width + "px");
    }
  },

  toggleResult : function(e) {
    this.$('.poll_progress_bar_wrapper').toggle();
    this.$('.percentage').toggle();
    if(this.toggleMode == 0) {
      this.$('.toggle_result').html(Diaspora.I18n.t("poll.close_result"));
      this.toggleMode = 1;
    }else{
      this.$('.toggle_result').html(Diaspora.I18n.t("poll.show_result"));
      this.toggleMode = 0;
    }
    return false;
  },

  refreshResult : function(answerId) {
    this.updateCounter(answerId);
    this.setProgressBar();
  },

  updateCounter : function(answerId) {
    this.poll.participation_count++;
    this.$('.poll_statistic').html(Diaspora.I18n.t("poll.count", {"count" : this.poll.participation_count}));
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
        parent.removeForm();
        parent.refreshResult(result);
        if(parent.toggleMode == 0) {
          parent.toggleResult(null);
        }

      }
    });
    return false;
  }

});