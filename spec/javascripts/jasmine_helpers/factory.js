var factory = {
  id : {
    current : 0,
    next : function(){
      return factory.id.current += 1;
    }
  },

  guid : function(){
    return 'omGUID' + this.id.next();
  },

  like : function(overrides){
    var defaultAttrs = {
      "created_at" : "2012-01-04T00:55:30Z",
      "author" : this.author(),
      "guid" : this.guid(),
      "id" : this.id.next()
    };

    return _.extend(defaultAttrs, overrides);
  },

  reshare: function(overrides) {
    var defaultAttrs = {
      "created_at": "2012-01-04T00:55:30Z",
      "author": this.author(),
      "guid": this.guid(),
      "id": this.id.next()
    };
    return _.extend(defaultAttrs, overrides);
  },

  aspectMembershipAttrs: function(overrides) {
    var id = this.id.next();
    var defaultAttrs = {
      "id": id,
      "aspect": factory.aspectAttrs()
    };

    return _.extend(defaultAttrs, overrides);
  },

  comment : function(overrides) {
    var defaultAttrs = {
      "created_at": "2012-01-04T00:55:30Z",
      "author": this.author(),
      "guid": this.guid(),
      "id": this.id.next(),
      "text": "This is a comment!"
    };

    overrides = overrides || {};
    overrides.post = this.post();
    return new app.models.Comment(_.extend(defaultAttrs, overrides));
  },

  contact: function(overrides) {
    var person = factory.personAttrs();
    var attrs = {
      "id": this.id.next(),
      "person_id": person.id,
      "person": person,
      "aspect_memberships": factory.aspectMembershipAttrs()
    };

    return new app.models.Contact(_.extend(attrs, overrides));
  },

  notification: function(overrides) {
    var noteId = this.id.next();
    var defaultAttrs = {
      "type": "reshared",
      "id": noteId,
      "target_type": "Post",
      "target_id": this.id.next(),
      "recipient_id": this.id.next(),
      "unread": true,
      "created_at": "2012-01-04T00:55:30Z",
      "updated_at": "2012-01-04T00:55:30Z",
      "note_html": "This is a notification!"
    };

    return new app.models.Notification(_.extend(defaultAttrs, overrides));
  },

  user : function(overrides) {
    return new app.models.User(factory.userAttrs(overrides));
  },

  userAttrs : function(overrides){
    var id = this.id.next();
    var defaultAttrs = {
      "name":"Awesome User" + id,
      "id": id,
      "diaspora_id": "bob@bob.com",
      "avatar":{
        "large":"http://localhost:3000/assets/user/default.png",
        "medium":"http://localhost:3000/assets/user/default.png",
        "small":"http://localhost:3000/assets/user/default.png"}
    };

    return _.extend(defaultAttrs, overrides);
  },

  postAttrs : function(){
    return  {
      "author": {},
      "provider_display_name" : null,
      "created_at" : "2012-01-03T19:53:13Z",
      "interacted_at" : '2012-01-03T19:53:13Z',
      "public" : false,
      "guid" : this.guid(),
      "o_embed_cache" : null,
      "open_graph_cache": null,
      "photos" : [],
      "text" : "jasmine is bomb",
      "id" : this.id.next(),
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
    };
  },

  profileAttrs: function(overrides) {
    var id = (overrides && overrides.id) ? overrides.id : factory.id.next();
    var defaults = {
      "bio": "I am a cat lover and I love to run",
      "birthday": "2012-04-17",
      "created_at": "2012-04-17T23:48:35Z",
      "diaspora_handle": "bob@localhost:3000",
      "first_name": "Bob",
      "full_name": "bob grimm",
      "gender": "robot",
      "id": id,
      "avatar": {
        "small": "http://localhost:3000/assets/user/default.png",
        "medium": "http://localhost:3000/assets/user/default.png",
        "large": "http://localhost:3000/assets/user/default.png"
      },
      "last_name": "Grimm",
      "location": "Earth",
      "nsfw": false,
      "person_id": "person" + id,
      "searchable": true,
      "updated_at": "2012-04-17T23:48:36Z"
    };
    return _.extend({}, defaults, overrides);
  },

  profile : function(overrides) {
    return new app.models.Profile(factory.profileAttrs(overrides));
  },

  personAttrs: function(overrides) {
    var id = (overrides && overrides.id) ? overrides.id : factory.id.next();
    var defaults = {
      "id": id,
      "guid": factory.guid(),
      "name": "Bob Grimm",
      "diaspora_id": "bob@localhost:3000",
      "relationship": "sharing",
      "block": false,
      "is_own_profile": false
    };
    return _.extend({}, defaults, overrides);
  },

  person: function(overrides) {
    return new app.models.Person(factory.personAttrs(overrides));
  },

  personWithProfile: function(overrides) {
    var profile_overrides = _.clone(overrides.profile);
    delete overrides.profile;
    var defaults = {
      profile: factory.profileAttrs(profile_overrides)
    };
    return factory.person(_.extend({}, defaults, overrides));
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
    }, overrides);
  },

  location : function() {
    return {
      address: "Starco Mart, Mission Street, San Francisco, Kalifornien, 94103, Vereinigte Staaten von Amerika",
      lat: 37.78,
      lng: -122.41
    };
  },

  post :  function(overrides) {
    var defaultAttrs = _.extend(factory.postAttrs(),  {"author" : this.author()});
    return new app.models.Post(_.extend(defaultAttrs, overrides));
  },

  postWithPoll :  function(overrides) {
    var defaultAttrs = _.extend(factory.postAttrs(), {"author": this.author()});
    defaultAttrs = _.extend(defaultAttrs, {"poll_participation_answer_id": null});
    defaultAttrs = _.extend(defaultAttrs, {"poll": factory.poll()});
    return new app.models.Post(_.extend(defaultAttrs, overrides));
  },

  postWithInteractions: function(overrides) {
    var likes = _.range(10).map(function() { return factory.like(); });
    var reshares = _.range(15).map(function() { return factory.reshare(); });
    var comments = _.range(20).map(function() { return factory.comment(); });
    var defaultAttrs = _.extend(factory.postAttrs(), {
      "author": this.author(),
      "interactions": {
        "reshares_count": 15,
        "likes_count": 10,
        "comments_count": 20,
        "comments": comments,
        "likes": likes,
        "reshares": reshares
      }
    });
    return new app.models.Post(_.extend(defaultAttrs, overrides));
  },

  statusMessage : function(overrides){
    //intentionally doesn't have an author to mirror creation process, maybe we should change the creation process
    return new app.models.StatusMessage(_.extend(factory.postAttrs(), overrides));
  },

  poll: function(){
    return {
      "question" : "This is an awesome question",
      "created_at" : "2012-01-03T19:53:13Z",
      "author" : this.author(),
      "post_id" : 1,
      "poll_answers" : [{"answer" : "yes", "id" : 1, "vote_count" : 9}, {"answer" : "no", "id" : 2, "vote_count" : 1}],
      "guid" : this.guid(),
      "poll_id": this.id.next(),
      "participation_count" : 10
    };
  },

  aspectAttrs: function(overrides) {
    var names = ['Work','School','Family','Friends','Just following','People','Interesting'];
    var defaultAttrs = {
      id: this.id.next(),
      name: names[Math.floor(Math.random()*names.length)]+' '+Math.floor(Math.random()*100),
      selected: false
    };

    return _.extend({}, defaultAttrs, overrides);
  },

  aspect: function(overrides) {
    return new app.models.Aspect(this.aspectAttrs(overrides));
  },

  aspectSelection: function(overrides) {
    return new app.models.AspectSelection(this.aspectAttrs(overrides));
  },

  preloads: function(overrides) {
    var defaults = {
      aspect_ids: []
    };

    window.gon = { preloads: {} };
    _.extend(window.gon.preloads, defaults, overrides);
  },

  pod: function(overrides) {
    var defaultAttrs = {
      "id": 4,
      "host": "pod.example.org",
      "port": null,
      "ssl": true,
      "status": "no_errors",
      "checked_at": "2020-01-01T13:37:00.000Z",
      "response_time": 100,
      "offline": false,
      "offline_since": null,
      "created_at": "2010-01-01T13:37:00.000Z",
      "software": "diaspora 1.2.3.0",
      "error": "ConnectionTester::Failure: #<Faraday::TimeoutError>"
    };
    return new app.models.Pod(_.extend(defaultAttrs, overrides));
  }
};

factory.author = factory.userAttrs;
