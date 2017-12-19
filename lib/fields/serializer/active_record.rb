require 'active_record'

module Fields
  module Serializer
    module ActiveRecord
      extend ActiveSupport::Concern

      class_methods do
        # Convert a list of fields (json_api notation) in a list of associations to be
        # added to a ActiveRecord Model.includes call
        #
        # Example:
        #
        #  BoilerPack.fields_to_includes("id,boiler.gas_safe_code") #=> ["boiler"]
        #
        def fields_to_includes(fields)
          nested_fields(fields).inject([{}]) do |result, attribute_structure|
            if attribute_structure.is_a?(Hash)
              result.first.deep_merge!(attribute_structure) { |_, u, v| u == v ? u : [u, v] }
            else
              result << attribute_structure unless result.first.dig(attribute_structure) || result.include?(attribute_structure)
            end
            result
          end.map(&:presence).compact
        end

        # Convert a list of fields (json_api notation) in a list of associations to be
        # added to a ActiveRecord Model.includes call
        #
        # Example:
        #
        #  BoilerPack.fields_to_includes("id,boiler.gas_safe_code") #=> ["boiler"]
        #
        def fields_to_include(fields, root: nil)
          Array(fields).map do |field|
            if field.kind_of?(Hash) || field.kind_of?(Array)
              field.map { |k, v| fields_to_include(v, root: composite_field(root, k)) }
            else
              composite_field(root, field)
            end
          end.flatten
        end

        def nested_field(attribute_stack)
          parent = attribute_stack.first
          return unless association?(parent)
          parent_klass = reflections[parent].class_name.constantize
          { parent => parent_klass.nested_field(attribute_stack[1..-1]) }.compact.presence || parent
        end

        private

        def array_fields(fields)
          Array(fields).map { |str| str.to_s.split(",").map(&:strip) }.flatten
        end

        def association?(key)
          reflections.keys.include?(key)
        end

        def composite_field(*values)
          values.compact.join(".")
        end

        def nested_fields(fields)
          array_fields(fields).map { |field| nested_field(field.split(".")) }.compact.uniq
        end
      end
    end
  end
end
