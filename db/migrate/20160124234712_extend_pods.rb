class ExtendPods < ActiveRecord::Migration[4.2]
  class Pod < ApplicationRecord
    has_many :people

    DEFAULT_PORTS = [URI::HTTP::DEFAULT_PORT, URI::HTTPS::DEFAULT_PORT]

    def self.find_or_create_by(opts)
      uri = URI.parse(opts.fetch(:url))
      port = DEFAULT_PORTS.include?(uri.port) ? nil : uri.port
      find_or_initialize_by(host: uri.host, port: port).tap do |pod|
        pod.ssl ||= (uri.scheme == "https")
        pod.save
      end
    end

    def url
      (ssl ? URI::HTTPS : URI::HTTP).build(host: host, port: port, path: "/")
    end
  end

  class Person < ApplicationRecord
    belongs_to :owner, class_name: "User"
    belongs_to :pod

    def url
      owner_id.nil? ? pod.url.to_s : AppConfig.url_to("/")
    end
  end

  class User < ApplicationRecord
    has_one :person, inverse_of: :owner, foreign_key: :owner_id
  end

  def up
    remove_index :pods, :host

    # add port
    add_column :pods, :port, :integer
    add_index :pods, %i(host port), unique: true, length: {host: 190, port: nil}, using: :btree

    add_column :pods, :blocked, :boolean, default: false

    Pod.reset_column_information

    # link people with pod
    add_column :people, :pod_id, :integer
    add_index :people, :url, length: 190
    add_foreign_key :people, :pods, name: :people_pod_id_fk, on_delete: :cascade
    Person.where(owner: nil).distinct(:url).pluck(:url).each do |url|
      pod = Pod.find_or_create_by(url: url)
      Person.where(url: url, owner_id: nil).update_all(pod_id: pod.id) if pod.persisted?
    end

    # cleanup unused pods
    Pod.joins("LEFT OUTER JOIN people ON pods.id = people.pod_id").where("people.id is NULL").delete_all

    remove_column :people, :url
  end

  def down
    # restore url
    add_column :people, :url, :text
    Person.all.group_by(&:pod_id).each do |pod_id, persons|
      Person.where(pod_id: pod_id).update_all(url: persons.first.url)
    end
    change_column :people, :url, :text, null: false
    remove_foreign_key :people, :pods
    remove_column :people, :pod_id

    # remove pods with port
    Pod.where.not(port: nil).delete_all

    remove_index :pods, column: %i(host port)
    remove_columns :pods, :port, :blocked
    add_index :pods, :host, unique: true, length: 190
  end
end
