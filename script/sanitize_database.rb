@start_time = Time.now.to_i
@count = 0

def sanitize_user(user)
  log "Sanitizing user #{@count += 1}:  #{user.username}"
  people = Person.all(:owner_id => user.id)
  log "#{user.username} has #{people.count} person objects."

  people.sort_by {|person| contact_count(person)}

  keep_person = people.last
  dumb_people = people[0..(people.count)]
  d_p_ids = dumb_people.map{|p| "ObjectId('#{p.id.to_s}')"}
  d_p_ids_json = "[#{d_p_ids.join(',')}]"

  ["posts", "comments", "contacts"].each do |table_name|
    eval_string = <<-JS
    db.#{table_name}.find({ "person_id" : {"$in" : #{d_p_ids_json}}}).forEach(function(document){
      db.#{table_name}.update({"_id" : document["_id"]}, {"$set" : { "person_id" : ObjectId("#{keep_person.id.to_s}")}});
    });
    JS
    MongoMapper.database.eval eval_string
  end

  ['from_id', 'to_id'].each do |key|
    eval_string = <<-JS
    db.requests.find({ "#{key}" : {"$in" : #{d_p_ids_json}}}).forEach(function(document){
      db.requests.update({"_id" : document["_id"]}, {"$set" : { "#{key}" : ObjectId("#{keep_person.id.to_s}")}});
    });
    JS
    MongoMapper.database.eval eval_string
  end

  "Ids for user #{user.username} set to one person"

  dumb_people.each{|dumb| dumb.delete}
  if user.serialized_private_key
    keep_person.serialized_public_key = OpenSSL::PKey::RSA.new(user.serialized_private_key).public_key
    keep_person.save
  else
    log "#{user.username} HAS NO ENCRYPTION KEY"
  end
end

def log string
 time_diff = Time.now.to_i - @start_time
 puts "#{time_diff}s; #{string}"
end

def contact_count person
  @contact_counts ||= {}
  return @contact_counts[person.id] if @contact_counts[person.id]
  query_result = @contacts_for_people_collection.find("_id" => person.id).first

  if query_result
    @contact_counts[person.id] = query_result["value"]
  else
    @contact_counts[person.id] = 0
  end

  @contact_counts[person.id]
end
def get_user_ids
  cmd = BSON::OrderedHash.new
  cmd["mapreduce"] = "people"
  cmd["map"] = 'function(){ emit(this["owner_id"], 1)};'
  cmd["reduce"] = 'function(key, vals) {' +
                'var sum=0;' +
                'for(var i in vals) sum += vals[i];' +
                'return sum;' +
                '};'
  result = MongoMapper.database.command(cmd)
  collection = MongoMapper.database.collection(result["result"])
  collection.find("value" => {"$gte" => 2}).map{|r| r["_id"]}
end

def contacts_for_people_collection
  cmd = BSON::OrderedHash.new
  cmd["mapreduce"] = "contacts"
  cmd["map"] = 'function(){ emit(this["person_id"], 1)};'
  cmd["reduce"] = 'function(key, vals) {' +
                'var sum=0;' +
                'for(var i in vals) sum += vals[i];' +
                'return sum;' +
                '};'
  result = MongoMapper.database.command(cmd)
  MongoMapper.database.collection(result["result"])
end

user_ids = get_user_ids

@contacts_for_people_collection = contacts_for_people_collection
users = User.where(:id.in => user_ids).all
log "#{users.size} Users retreived."
users.each{ |user| sanitize_user(user) }

log "Eliminating local people with no corresponding user."

MongoMapper.database.eval <<-MOREJS
db.people.find().forEach(
	function(doc){
		if(doc["owner_id"] != null && db.users.count({"_id" : doc["owner_id"]}) == 0){
		 db.people.remove({"_id" : doc["_id"]});
		}
	}
);
MOREJS

def dup_user_emails
  cmd = BSON::OrderedHash.new
  cmd["mapreduce"] = "users"
  cmd["map"] = 'function(){ emit(this["email"], 1)};'
  cmd["reduce"] = 'function(key, vals) {' +
                'var sum=0;' +
                'for(var i in vals) sum += vals[i];' +
                'return sum;' +
                '};'
  result = MongoMapper.database.command(cmd)
  coll = MongoMapper.database.collection(result["result"])
  user_emails = coll.find("value" => {"$gte" => 2}).map{|r| r["_id"]}
end

emails = dup_user_emails
log "Eliminating #{emails.count} users with duplicate emails"

users_coll = MongoMapper.database.collection("users")
users_coll.remove("email" => {"$in" => emails})

def dup_requests
  cmd = BSON::OrderedHash.new
  cmd["mapreduce"] = "requests"
  cmd["map"] = 'function(){ emit(this["from_id"].toString() + "," + this["to_id"].toString(), {"array" : [this["_id"]], "count" : 1 })};'
  cmd["reduce"] = 'function(key, vals) {' +
                    'var result = {"array" : [], "count" : 0};' +
                    'for(var i in vals){' +
                      'result["array"] = result["array"].concat(vals[i]["array"]);' +
                      'result["count"] += vals[i]["count"];' +
                    '}' +
                    'return result;' +
                  '};'
  result = MongoMapper.database.command(cmd)
  coll = MongoMapper.database.collection(result["result"])
  #FIND WHERE "array" size is greater than 1
  coll.find({"value.count" => {"$gte" => 2}}).map{|r| r["value"]["array"]}
end
non_unique_requests = dup_requests
non_unique_requests.each{|request_id_array| request_id_array.pop}
non_unique_requests.flatten!

log "Eliminating #{non_unique_requests.length} duplicate requests"
req_coll = MongoMapper.database.collection("requests")
req_coll.remove("_id" => {"$in" => non_unique_requests})

def dup_contacts
  cmd = BSON::OrderedHash.new
  cmd["mapreduce"] = "contacts"
  cmd["map"] = 'function(){ emit(this["person_id"].toString() + "," + this["user_id"].toString(), {"array" : [this["_id"]], "count" : 1 })};'
  cmd["reduce"] = 'function(key, vals) {' +
                    'var result = {"array" : [], "count" : 0};' +
                    'for(var i in vals){' +
                      'result["array"] = result["array"].concat(vals[i]["array"]);' +
                      'result["count"] += vals[i]["count"];' +
                    '}' +
                    'return result;' +
                  '};'
  result = MongoMapper.database.command(cmd)
  coll = MongoMapper.database.collection(result["result"])
  #FIND WHERE "array" size is greater than 1
  coll.find({"value.count" => {"$gte" => 2}}).map{|r| r["value"]["array"]}
end
non_unique_contacts = dup_contacts
non_unique_contacts.each{|contact_id_array| contact_id_array.pop}
non_unique_contacts.flatten!

log "Eliminating #{non_unique_contacts.length} duplicate contacts"
req_coll = MongoMapper.database.collection("contacts")
req_coll.remove("_id" => {"$in" => non_unique_contacts})
