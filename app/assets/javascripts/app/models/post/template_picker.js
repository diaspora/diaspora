//require ../post

app.models.Post.TemplatePicker = function(model){
  this.model = model
}

_.extend(app.models.Post.TemplatePicker.prototype, {
  getFrameName : function getFrameName() {
    var frameName

    if(this.isNewspaper()){
      frameName = "Newspaper"
    } else if(this.isWallpaper()) {
      frameName =  "Wallpaper"
    } else {
      frameName = "Day"
    }

    return frameName
  },

  isNewspaper : function(){
    return this.model.get("text").length > 300
  },

  isWallpaper : function(){
    return this.model.get("photos").length == 1
  }
});