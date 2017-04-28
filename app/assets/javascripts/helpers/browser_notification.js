Diaspora.BrowserNotification = {
  requestPermission: function() {
    if ("Notification" in window && Notification.permission !== "granted" && Notification.permission !== "denied") {
      Notification.requestPermission();
    }
  },

  spawnNotification: function(title, summary) {
    if ("Notification" in window && Notification.permission === "granted") {
      if (!_.isString(title)) {
        throw new Error("No notification title given.");
      }

      summary = summary || "";

      new Notification(title, {
        body: summary,
        icon: ImagePaths.get("branding/logos/asterisk_white_mobile.png")
      });
    }
  }
};
