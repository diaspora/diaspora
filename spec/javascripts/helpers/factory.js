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
      "public" : false,
      "guid" : this.guid(),
      "image_url" : null,
      "o_embed_cache" : null,
      "open_graph_cache": null,
      "photos" : [],
      "text" : "jasmine is bomb",
      "id" : this.id.next(),
      "object_url" : null,
      "root" : null,
      "post_type" : "StatusMessage",
      "interactions" : {
        "reshares_count" : 0,
        "likes_count" : 0,
        "comments_count" : 0,
        "comments" : [],
        "likes" : [],
        "reshares" : []
      }
    }
  },

  profile : function(overrides) {
    var id = overrides && overrides.id || factory.id.next()
    var defaults = {
      "bio": "I am a cat lover and I love to run",
      "birthday": "2012-04-17",
      "created_at": "2012-04-17T23:48:35Z",
      "diaspora_handle": "bob@localhost:3000",
      "first_name": "Bob",
      "full_name": "bob grimm",
      "gender": "robot",
      "id": id,
      "image_url": "http:\/\/localhost:3000\/assets\/user\/wolf.jpg",
      "image_url_medium": "http:\/\/localhost:3000\/assets\/user\/wolf.jpg",
      "image_url_small": "http:\/\/localhost:3000\/assets\/user\/wolf.jpg",
      "last_name": "Grimm",
      "location": "Earth",
      "nsfw": false,
      "person_id": "person" + id,
      "searchable": true,
      "updated_at": "2012-04-17T23:48:36Z"
    }

    return new app.models.Profile(_.extend(defaults, overrides))
  },

  photoAttrs : function(overrides){
    var id = this.id.next();
    return _.extend({
      author: factory.userAttrs(),
      created_at: "2012-03-27T20:11:52Z",
      guid: "8b0db16a4c4307b2" + id,
      id: id,
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

  postWithPoll :  function(overrides) {
    defaultAttrs = _.extend(factory.postAttrs(),  {"author" : this.author()});
    defaultAttrs = _.extend(defaultAttrs,  {"already_participated_in_poll" : false});
    defaultAttrs = _.extend(defaultAttrs,  {"poll" : factory.poll()});
    return new app.models.Post(_.extend(defaultAttrs, overrides));
  },

  statusMessage : function(overrides){
    //intentionally doesn't have an author to mirror creation process, maybe we should change the creation process
    return new app.models.StatusMessage(_.extend(factory.postAttrs(), overrides))
  },

  poll: function(overrides){
    return {
      "question" : "This is an awesome question",
      "created_at" : "2012-01-03T19:53:13Z",
      "author" : this.author(),
      "post_id" : 1,
      "poll_answers" : [{"answer" : "yes", "id" : 1, "vote_count" : 9}, {"answer" : "no", "id" : 2, "vote_count" : 1}],
      "guid" : this.guid(),
      "poll_id": this.id.next(),
      "participation_count" : 10
    }
  },

  comment: function(overrides) {
    var defaultAttrs = {
      id:     this.id.next(),
      guid:   this.guid(),
      text:   "This is an awesome comment!",
      author: this.author(),
      created_at: "2012-01-03T19:53:13Z"
    };

    return new app.models.Comment(_.extend(defaultAttrs, overrides))
  },

  preloads: function(overrides) {
    var defaults = {
      aspect_ids: []
    };

    window.gon = { preloads: {} };
    _.extend(window.gon.preloads, defaults, overrides);
  }
}

factory.author = factory.userAttrs;
