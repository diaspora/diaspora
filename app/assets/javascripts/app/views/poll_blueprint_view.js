//= require ./poll_view
app.views.PollBlueprint = app.views.Poll.extend({
  templateName: 'poll_blueprint',
  
  initialize: function(options) {
    this.constructor.__super__.initialize.apply(this, options);
    this.progressBarFactor = 3;
  },
  setProgressBarData: function(progressBar, percent) {
    progressBar.css('width', percent * this.progressBarFactor + 'px');
    progressBar.parent().next().html(" - " + percent + "%");
  },
  toggleElements: function() {
    this.$('.poll_progress_bar_wrapper').toggle();
    this.$('.percentage').toggle();
  }
});
