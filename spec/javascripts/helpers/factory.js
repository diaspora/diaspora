factory = {
  id : {
    current : 0,
    next : function(){
      return factory.id.current += 1
    }
  },

  guid : function(){
    return 'omGUID' + this.id.next()
  },

  like : function(overrides){
    var defaultAttrs = {
      "created_at" : "2012-01-04T00:55:30Z",
      "author" : this.author(),
      "guid" : this.guid(),
      "id" : this.id.next()
    }

    return _.extend(defaultAttrs, overrides)
  },

  comment : function(overrides) {
    var defaultAttrs = {
      "created_at" : "2012-01-04T00:55:30Z",
      "author" : this.author(),
      "guid" : this.guid(),
      "id" : this.id.next(),
      "text" : "This is a comment!"
    }
    
    return new app.models.Comment(_.extend(defaultAttrs, overrides))
  },

  user : function(overrides) {
    return new app.models.User(factory.userAttrs(overrides))
  },

  userAttrs : function(overrides){
    var id = this.id.next()
    var defaultAttrs = {
      "name":"Awesome User" + id,
      "id": id,
      "diaspora_id": "bob@bob.com",
      "avatar":{
        "large":"http://localhost:3000/images/user/uma.jpg",
        "medium":"http://localhost:3000/images/user/uma.jpg",
        "small":"http://localhost:3000/images/user/uma.jpg"}
    }

    return _.extend(defaultAttrs, overrides)
  },

  postAttrs : function(){
    return  {
      "provider_display_name" : null,
      "created_at" : "2012-01-03T19:53:13Z",
      "interacted_at" : '2012-01-03T19:53:13Z',
      "last_three_comments" : null,
      "public" : false,
      "guid" : this.guid(),
      "image_url" : null,
      "o_embed_cache" : null,
      "photos" : [],
      "text" : "jasmine is bomb",
      "reshares_count" : 0,
      "id" : this.id.next(),
      "object_url" : null,
      "root" : null,
      "post_type" : "StatusMessage",
      "likes_count" : 0,
      "comments_count" : 0
    }
  },

  photoAttrs : function(overrides){
    return _.extend({
      author: factory.userAttrs(),
      created_at: "2012-03-27T20:11:52Z",
      guid: "8b0db16a4c4307b2",
      id: 117,
      sizes: {
          large: "http://localhost:3000/uploads/images/scaled_full_d85410bd19db1016894c.jpg",
          medium: "http://localhost:3000/uploads/images/thumb_medium_d85410bd19db1016894c.jpg",
          small: "http://localhost:3000/uploads/images/thumb_small_d85410bd19db1016894c.jpg"
        }
    }, overrides)
  },

  post :  function(overrides) {
    defaultAttrs = _.extend(factory.postAttrs(),  {"author" : this.author()})
    return new app.models.Post(_.extend(defaultAttrs, overrides))
  },

  statusMessage : function(overrides){
    //intentionally doesn't have an author to mirror creation process, maybe we should change the creation process
    return new app.models.StatusMessage(_.extend(factory.postAttrs(), overrides))
  },

  comment: function(overrides) {
    var defaultAttrs = {
      "text" : "This is an awesome comment!",
      "created_at" : "2012-01-03T19:53:13Z",
      "author" : this.author(),
      "guid" : this.guid(),
      "id": this.id.next()
    }

    return new app.models.Comment(_.extend(defaultAttrs, overrides))
  }
}

factory.author = factory.userAttrs
