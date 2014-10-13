Backbone.Draftable = function() {
  var _model = this;
  var draftAttributes;
  var timerId;

  _.extend(this, {
    saveDraft : function() {
      var modelAttributesJSON = JSON.stringify(_model.attributes);

      // If this is the first change, or the model has changed since the last 
      // draft, store in localStorage
      if (!draftAttributes || JSON.stringify(draftAttributes) !== modelAttributesJSON) {
        localStorage.setItem('message', modelAttributesJSON);
        draftAttributes = _(_model.attributes).clone();
      }
    },

    getDraft : function() {
      return JSON.parse(localStorage.getItem("message"));
    },

    startMonitoring : function() {
      timerId = setInterval(_model.saveDraft, 1000);
    },

    stopMonitoring : function() {
      clearInterval(timerId);
    },

    restartTimer: function() {
      _model.stopMonitoring();
      _model.startMonitoring();
    }
  });

  // Set the model attributes from the draft in localStorage, if available.
   _model.set(_model.getDraft());

  // reset timer everytime a change is made to draft
   _model.listenTo(_model, 'change', _model.restartTimer);
};