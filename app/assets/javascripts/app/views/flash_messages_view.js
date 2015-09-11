app.views.FlashMessages = app.views.Base.extend({
  templateName: "flash_messages",

  _flash: function(message, error){
    this.presenter = {
      message: message,
      alertLevel: error ? "alert-danger" : "alert-success"
    };

    this.renderTemplate();
  },

  success: function(message){
    this._flash(message, false);
  },

  error: function(message){
    this._flash(message, true);
  }
});
