require 'active_record'
require "active_model_serializers"

module Fields
  module Serializer

    class FieldsTree
      attr_reader :klass, :fields, :associations

      def initialize(klass)
        @klass        = klass
        @fields       = []
        @associations = {}
      end
      
      def presence
        self if fields.present? || associations.present?
      end
      
      def merge!(join_field)
        return self unless join_field.present?
        parent, rest = join_field.to_s.split(".", 2)
        if rest.blank?
          fields << parent if !(existing_field?(parent) || association?(parent))
        else
          existing_association?(parent) ? associations[parent].merge!(rest) : add_association!(parent, rest)
        end
        self
      end
      
      def notation
        if fields.present?
          if associations.present?
            fields.dup << associations_to_notation
          else
            fields.one? ? fields.first.dup : fields.dup
          end
        else
          associations_to_notation.presence
        end
      end
      
      def to_includes
        to_includes = associations.inject([]) do |result, (k, v)|
          v_includes = v.to_includes
          if v_includes.present?
            new_has_entry = { k => v_includes }
            hash = result.find { |e| e.is_a?(Hash) }
            hash ? hash.merge!(new_has_entry) : (result << new_has_entry)
            result
          else
            result << k
          end
        end.presence
        Array(to_includes).one? ? to_includes.first : to_includes
      end
      
      def to_s
        notation.to_s
      end
      
      private
      
      def add_association!(parent, rest)
        if association?(parent)
          nested_class       = klass.reflections[parent].klass
          nested_fields_tree = FieldsTree.new(nested_class).merge!(rest).presence
          new_association    = { parent => nested_fields_tree } if nested_fields_tree
          associations.merge!(new_association) if new_association
        end
      end
      
      def associations_to_notation
        associations.inject({}) do |result, (k, v)|
          result.merge!(k => v.notation)
        end
      end
      
      def existing_association?(value)
        !!associations[value]
      end
      
      def existing_field?(value)
        fields.include?(value)
      end

      def association?(value)
        klass.reflections.keys.include?(value)
      end
    end
  end
end
