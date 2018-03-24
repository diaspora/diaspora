(function() {
  Diaspora.Mobile.Alert = {
    _flash: function(message, type) {
      var html = "<div class='alert alert-" + type + " alert-dismissible fade in' role='alert'>" +
                    "<button type='button' class='close' data-dismiss='alert' aria-label='" +
                      Diaspora.I18n.t("header.close") +
                    "'>" +
                      "<span aria-hidden='true'><i class='entypo-cross'></i></span>" +
                    "</button>" +
                    message +
                  "</div>";
      $("#flash-messages").append(html);
    },

    success: function(message) { this._flash(message, "success"); },

    error: function(message) { this._flash(message, "danger"); },

    handleAjaxError: function(response) {
      if (response.status === 0) {
        this.error(Diaspora.I18n.t("errors.connection"));
      } else {
        this.error(response.responseText);
      }
    }
  };
})();
