app.models.Draft = Backbone.Model.extend({

  saveDraft : function() {
    localStorage.setItem('message', JSON.stringify(this.attributes) );
  },

  getDraft : function() {
    return JSON.parse(localStorage.getItem("message"));
  },

  startMonitoring : function() {
    timerId = setInterval(this.model.saveDraft, 500);
  },

  stopMonitoring : function() {
    clearInterval(timerId);
  }
});
