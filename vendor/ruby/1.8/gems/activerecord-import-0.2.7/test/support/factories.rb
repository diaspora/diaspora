Factory.define :group do |m|
  m.sequence(:order) { |n| "Order #{n}" }
end

Factory.define :invalid_topic, :class => "Topic" do |m|
  m.sequence(:title){ |n| "Title #{n}"}
  m.author_name nil
end

Factory.define :topic do |m|
  m.sequence(:title){ |n| "Title #{n}"}
  m.sequence(:author_name){ |n| "Author #{n}"}
end