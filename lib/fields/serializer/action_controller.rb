require 'action_controller'

module Fields
  module Serializer
    module ActionController
      extend ActiveSupport::Concern

      # Render the result of an ActiveRecord::Relation query including only the fields specified
      #
      # @param  [ActiveRecord::Relation] query - The query to render in json
      # @param  [Boolean] optimize_query       - Add outer joins to the query to prevent a db query per serialized object.
      # @option options [Array] :fields        - The list of fields to return in json api syntax
      # @option options [Class] :model_class   - The model class of the objects to be queried to optimize db hits.
      # @option options [Hash]  :options       - Any other valid option to render method.
      def render_json_fields(query, optimize_query: true, **options)
        fields      = options.delete(:fields)
        model_class = options.delete(:model_class)
        if fields.present?
          if optimize_query
            includes = model_class.fields_to_includes(fields)
            query    = query.includes(*includes)  if includes
          end
          options.merge!(each_serializer: model_class.fields_serializer(fields), include: "**")
        end
        render options.merge!(json: query.to_a)
      end
    end
  end
end
