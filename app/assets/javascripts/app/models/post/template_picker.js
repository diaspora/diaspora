//require ../post

app.models.Post.TemplatePicker = function(model){
  this.model = model
}

_.extend(app.models.Post.TemplatePicker.prototype, {
  getFrameName : function getFrameName() {
    var frameName

    if(this.isNewspaper()){
      frameName = "Typist"
    } else if(this.isWallpaper()) {
      frameName =  "Wallpaper"
    } else {
      frameName = "Vanilla"
    }

    return frameName
  },

  isNewspaper : function(){
    return this.model.get("text").length > 300
  },

  isWallpaper : function(){
    return this.model.get("photos").length == 1
  },

  applicableTemplates : function(){
    /* don't show the wallpaper option if there is no image */
    var moods = app.models.Post.frameMoods;
    return (!this.isWallpaper() ? _.without(moods, "Wallpaper") : moods)
  }
});