require 'action_controller'

module Fields
  module Serializer
    module ActionController
      extend ActiveSupport::Concern


      # Render the result of an ActiveRecord query including only the fields specified if any
      #   or the whole serialized objects.
      #
      # @param  [ActiveRecord_Relation] query - The query to render in json
      # @option options [Array] :fields       - The list of fields to return in json api syntax
      # @option options [Class] :model_class  - The model class of the objects to be queried to optimize db hits.
      # @option options [Hash]  :options      - Any other valid option to render method.
      def render_json_fields(query, **options)
        fields      = options.delete(:fields)
        model_class = options.delete(:model_class)
        if fields.present?
          query = query.includes(*model_class.fields_to_includes(fields))
          options.merge!(each_serializer: model_class.fields_serializer(fields))
          options.delete(:include)
        end
        render options.merge!(json: query.to_a)
      end
    end
  end
end
