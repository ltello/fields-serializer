require 'active_record'

module Fields
  module Serializer
    module ActiveRecord
      extend ActiveSupport::Concern

      class_methods do
        def fields_to_includes(fields)
          flatten_fields = Array(fields).map { |str| str.to_s.split(",").map(&:strip) }.flatten
          nested_fields  = flatten_fields.map { |field| nested_field(field.split(".")) }.compact
          nested_fields.inject([{}]) do |result, attribute_structure|
            if attribute_structure.is_a?(Hash)
              result.first.deep_merge!(attribute_structure) { |_, u, v| [u, v] } && result
            else
              result << attribute_structure
            end
          end.map(&:presence).compact
        end

        private

        def association?(key)
          reflections.keys.include?(key)
        end

        def nested_field(attribute_stack)
          parent = attribute_stack.first
          return unless association?(parent)
          parent_klass = reflections[parent].class_name.constantize
          { parent => parent_klass.nested_field(attribute_stack[1..-1]) }.compact.presence || parent
        end
      end
    end
  end
end
