# frozen_string_literal: true

module Api
  module V1
    class SearchController < Api::V1::BaseController
      USER_FILTER_CONTACTS = "contacts"
      USER_FILTER_RECEIVING_CONTACTS = "contacts:receiving"
      USER_FILTER_SHARING_CONTACTS = "contacts:sharing"
      USER_FILTER_ASPECTS_PREFIX = "aspect:"
      USER_FILTERS_EXACT_MATCH = [USER_FILTER_CONTACTS, USER_FILTER_RECEIVING_CONTACTS,
                                  USER_FILTER_SHARING_CONTACTS].freeze
      USER_FILTERS_PREFIX_MATCH = [USER_FILTER_ASPECTS_PREFIX].freeze

      before_action do
        require_access_token %w[public:read]
      end

      rescue_from ActionController::ParameterMissing, RuntimeError do |e|
        render_error 422, e.message
      end

      def user_index
        user_page = index_pager(people_query).response
        user_page[:data] = user_page[:data].map {|p| PersonPresenter.new(p).as_api_json }
        render_paged_api_response user_page
      end

      def post_index
        posts_page = time_pager(posts_query, "posts.created_at", "created_at").response
        posts_page[:data] = posts_page[:data].map {|post| PostPresenter.new(post).as_api_response }
        render_paged_api_response posts_page
      end

      def tag_index
        tags_page = index_pager(tags_query).response
        tags_page[:data] = tags_page[:data].pluck(:name)
        render_paged_api_response tags_page
      end

      private

      def time_pager(query, query_time_field, data_time_field)
        Api::Paging::RestPaginatorBuilder.new(query, request).time_pager(params, query_time_field, data_time_field)
      end

      def people_query
        tag = params[:tag]
        name_or_handle = params[:name_or_handle]
        raise "Parameters tag and name_or_handle are exclusive" if tag.present? && name_or_handle.present?

        query = if tag.present?
                  # scope filters to only searchable people already
                  Person.profile_tagged_with(tag)
                elsif name_or_handle.present?
                  Person.searchable(contacts_read? && current_user) # rubocop:disable Rails/DynamicFindBy
                        .find_by_substring(name_or_handle)
                else
                  raise "Missing parameter tag or name_or_handle"
                end

        query = query.where(closed_account: false)

        user_filters.each do |filter|
          query = query.contacts_of(current_user) if filter == USER_FILTER_CONTACTS

          if filter == USER_FILTER_RECEIVING_CONTACTS
            query = query.contacts_of(current_user).where(contacts: {receiving: true})
          end

          if filter == USER_FILTER_SHARING_CONTACTS
            query = query.contacts_of(current_user).where(contacts: {sharing: true})
          end

          if filter.start_with?(USER_FILTER_ASPECTS_PREFIX) # rubocop:disable Style/Next
            _, ids = filter.split(":", 2)
            ids = ids.split(",").map {|id|
              Integer(id) rescue raise("Invalid aspect filter") # rubocop:disable Style/RescueModifier
            }

            raise "Invalid aspect filter" unless current_user.aspects.where(id: ids).count == ids.size

            query = Person.where(id: query.all_from_aspects(ids, current_user).select(:id))
          end
        end

        query.distinct
      end

      def posts_query
        if private_read?
          Stream::Tag.new(current_user, params.require(:tag)).posts
        else
          Stream::Tag.new(nil, params.require(:tag)).posts
        end
      end

      def tags_query
        ActsAsTaggableOn::Tag.autocomplete(params.require(:query))
      end

      def user_filters
        @user_filters ||= Array(params[:filter]).uniq.tap do |filters|
          raise "Invalid filter" unless filters.all? {|filter|
            USER_FILTERS_EXACT_MATCH.include?(filter) ||
            USER_FILTERS_PREFIX_MATCH.any? {|prefix| filter.start_with?(prefix) }
          }

          # For now all filters require contacts:read
          require_access_token %w[contacts:read] unless filters.empty?
        end
      end

      def contacts_read?
        access_token? %w[contacts:read]
      end
    end
  end
end
