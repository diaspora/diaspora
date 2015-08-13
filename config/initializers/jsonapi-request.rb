JSONAPI.configure do |config|
  config.raise_if_parameters_not_allowed = false
  config.resource_key_type = :string
end

JSONAPI::ActsAsResourceController.class_eval do
  def create_response_document(operation_results)
    JSONAPI::ResponseDocument.new(
      operation_results,
      primary_resource_klass:    resource_klass,
      include_directives:        @request ? @request.include_directives : nil,
      fields:                    @request ? @request.fields : nil,
      base_url:                  base_url,
      key_formatter:             key_formatter,
      route_formatter:           route_formatter,
      base_meta:                 base_meta,
      base_links:                base_response_links,
      resource_serializer_klass: resource_serializer_klass,
      request:                   @request,
      serialization_options:     serialization_options,
      custom_fetch_proc:         params[:custom_fetch_proc]
    )
  end
end

JSONAPI::ResponseDocument.class_eval do
  def serializer
    @serializer ||= @options.fetch(:resource_serializer_klass, JSONAPI::ResourceSerializer).new(
      @options.fetch(:primary_resource_klass),
      include_directives:    @options[:include_directives],
      fields:                @options[:fields],
      base_url:              @options.fetch(:base_url, ""),
      key_formatter:         @key_formatter,
      route_formatter:       @options.fetch(:route_formatter, JSONAPI.configuration.route_formatter),
      serialization_options: @options.fetch(:serialization_options, {}),
      custom_fetch_proc:     @options[:custom_fetch_proc]
    )
  end
end

JSONAPI::ResourceSerializer.class_eval do
  def initialize(primary_resource_klass, options={})
    @primary_class_name = primary_resource_klass._type
    @fields             = options.fetch(:fields, {})
    @include            = options.fetch(:include, [])
    @include_directives = options[:include_directives]
    @key_formatter      = options.fetch(:key_formatter, JSONAPI.configuration.key_formatter)
    @link_builder       = generate_link_builder(primary_resource_klass, options)
    @always_include_to_one_linkage_data = options.fetch(:always_include_to_one_linkage_data,
                                                        JSONAPI.configuration.always_include_to_one_linkage_data)
    @always_include_to_many_linkage_data = options.fetch(:always_include_to_many_linkage_data,
                                                         JSONAPI.configuration.always_include_to_many_linkage_data)
    @serialization_options = options.fetch(:serialization_options, {})
    @custom_fetch_proc = options[:custom_fetch_proc]
  end

  def foreign_key_types_and_values(source, relationship)
    if relationship.is_a?(JSONAPI::Relationship::ToMany)
      if relationship.polymorphic?
        source._model.public_send(relationship.name).pluck(:type, :id).map do |type, id|
          [type.pluralize, IdValueFormatter.format(id)]
        end
      else
        @custom_fetch_proc.call(source)
      end
    end
  end
end

JSONAPI::Request.class_eval do
  def setup_get_related_resource_action(params)
    initialize_source(params)
    parse_fields(params[:fields])
    parse_include_directives(params[:include])
    set_default_filters
    parse_filters(params[:filter])
    parse_sort_criteria(params[:sort])
    parse_pagination(params[:page])
    add_show_modified_related_resource_operation(params[:relationship], params[:custom_fetch_proc])
  end

  def setup_get_related_resources_action(params)
    initialize_source(params)
    parse_fields(params[:fields])
    parse_include_directives(params[:include])
    set_default_filters
    parse_filters(params[:filter])
    parse_sort_criteria(params[:sort])
    parse_pagination(params[:page])
    add_show_modified_related_resources_operation(params[:relationship], params[:custom_fetch_proc])
  end

  def add_show_modified_related_resource_operation(relationship_type, custom_fetch_proc)
    @operations.push JSONAPI::ShowRelatedResourceOperation.new(
      @resource_klass,
      context:           @context,
      relationship_type: relationship_type,
      custom_fetch_proc: custom_fetch_proc,
      source_klass:      @source_klass,
      source_id:         @source_id
    )
  end

  def add_show_modified_related_resources_operation(relationship_type, custom_fetch_proc)
    @operations.push JSONAPI::ShowRelatedResourcesOperation.new(
      @resource_klass,
      context:           @context,
      relationship_type: relationship_type,
      custom_fetch_proc: custom_fetch_proc,
      source_klass:      @source_klass,
      source_id:         @source_id,
      filters:           @source_klass.verify_filters(@filters, @context),
      sort_criteria:     @sort_criteria,
      paginator:         @paginator
    )
  end
end

JSONAPI::ShowRelatedResourceOperation.class_eval do
  attr_reader :source_klass, :source_id, :relationship_type, :custom_fetch_proc

  def initialize(resource_klass, options={})
    super(resource_klass, options)
    @source_klass = options.fetch(:source_klass)
    @source_id = options.fetch(:source_id)
    @relationship_type = options.fetch(:relationship_type)
    @custom_fetch_proc = options.fetch(:custom_fetch_proc)
    @transactional = false
  end

  def apply
    source_resource = @source_klass.find_by_key(@source_id, context: @context)
    if @custom_fetch_proc
      related_resource = @custom_fetch_proc.call(source_resource)
    else
      related_resource = source_resource.public_send(@relationship_type)
    end
    return JSONAPI::ResourceOperationResult.new(:ok, related_resource)
  rescue JSONAPI::Exceptions::Error => e
    return JSONAPI::ErrorsOperationResult.new(e.errors[0].code, e.errors)
  rescue StandardError => e
    return JSONAPI::ErrorsOperationResult.new(e.errors[0].code, e.errors)
  end
end

JSONAPI::ShowRelatedResourcesOperation.class_eval do
  attr_reader :source_klass, :source_id, :relationship_type, :filters, :sort_criteria, :paginator, :custom_fetch_proc

  def initialize(resource_klass, options={})
    super(resource_klass, options)
    @source_klass = options.fetch(:source_klass)
    @source_id = options.fetch(:source_id)
    @relationship_type = options.fetch(:relationship_type)
    @filters = options[:filters]
    @sort_criteria = options[:sort_criteria]
    @paginator = options[:paginator]
    @custom_fetch_proc = options.fetch(:custom_fetch_proc)
    @transactional = false
  end

  def apply
    if @custom_fetch_proc
      related_resource = @custom_fetch_proc.call(source_resource)
    else
      related_resource = source_resource.public_send(@relationship_type,
                                                     filters:       @filters,
                                                     sort_criteria: @sort_criteria,
                                                     paginator:     @paginator)
    end
    return JSONAPI::RelatedResourcesOperationResult.new(
      :ok, source_resource, @relationship_type, related_resource, options)

  rescue JSONAPI::Exceptions::Error => e
    return JSONAPI::ErrorsOperationResult.new(e.errors[0].code, e.errors)
  rescue StandardError => e
    return JSONAPI::ErrorsOperationResult.new(e.errors[0].code, e.errors)
  end
end
