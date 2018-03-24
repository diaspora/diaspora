// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Poll = app.views.Base.extend({
  templateName: "poll",

  events: {
    "click .submit" : "clickSubmit",
    "click .toggle-result": "toggleResult"
  },

  initialize: function() {
    this.model.bind('change', this.render, this);
  },

  presenter: function(){
    var defaultPresenter = this.defaultPresenter();
    var isReshare = (this.model.get('post_type') === 'Reshare');
    var showForm = defaultPresenter.loggedIn &&
                   !isReshare &&
                   !this.model.get("poll_participation_answer_id");
    var originalPostLink = isReshare && this.model.get('root') ?
      '<a href="/posts/' + this.model.get('root').id + '" class="root_post_link">' + Diaspora.I18n.t('poll.original_post') + '</a>' :
      '';
    var answerGiven = this.model.get("poll_participation_answer_id");

    if (defaultPresenter.poll && defaultPresenter.poll.poll_answers) {
      defaultPresenter.poll.poll_answers.forEach(function(answer) {
        _.extend(answer, {isCurrentUserVote: answerGiven ? answer.id === answerGiven : false});
      });
    }

    return _.extend(defaultPresenter, {
      show_form: showForm,
      is_reshare: isReshare,
      originalPostLink: originalPostLink
    });
  },

  postRenderTemplate: function() {
    this.poll = this.model.attributes.poll;
    this.pollButtons();
    this.setProgressBar();
  },

  setProgressBar: function() {
    if(!this.poll) return;

    var answers = this.poll.poll_answers;
    var participation_count = this.poll.participation_count;
    var _this = this;

    _.each(answers, function(answer){
      var percent = 0;
      if(participation_count > 0) {
        percent = Math.round(answer.vote_count / participation_count * 100);
      }

      var progressBar = _this.$(".progress-bar[data-answerid=" + answer.id + "]");

      _this.setProgressBarData(progressBar, percent);
    });
  },

  setProgressBarData: function(progressBar, percent) {
    progressBar.css("width", percent + "%");
    progressBar.parents('.result-row').find('.percentage').text(percent + "%");
  },

  pollButtons: function() {
    if(!this.poll || !this.poll.post_id) {
      this.$(".submit").attr("disabled", true);
      this.$(".toggle-result").attr("disabled", true);
    }
  },

  toggleResult: function(evt) {
    if(evt) {
      evt.preventDefault();
      // Disable link
      if($(evt.target).attr('disabled')) {
        return false;
      }
    }
    this.toggleElements();

    var toggleResult = this.$(".toggle-result");

    if(!this.toggleMode) {
      toggleResult.html(Diaspora.I18n.t("poll.close_result"));
      this.toggleMode = 1;
    }
    else {
      toggleResult.html(Diaspora.I18n.t("poll.show_result"));
      this.toggleMode = 0;
    }
  },

  toggleElements: function() {
    this.$(".poll-result").toggle();
    this.$(".progress").toggle();
  },

  clickSubmit: function(evt) {
    evt.preventDefault();

    var answer_id = parseInt(this.$("input[name=vote]:checked").val());
    this.vote(answer_id);
  },

  vote: function(answer_id){
    var pollParticipation = new app.models.PollParticipation({
      poll_answer_id: answer_id,
      poll_id: this.poll.poll_id,
      post_id: this.poll.post_id,
    });
    var _this = this;

    pollParticipation.save({},{
      success : function() {
        _this.model.fetch();
      }
    });
  }

});
// @license-end
