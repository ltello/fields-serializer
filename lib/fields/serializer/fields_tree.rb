require 'active_record'
require "active_model_serializers"

module Fields
  module Serializer

    # A class to store a tree structure of a model klass, its attributes and associations.
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
      
      # Adds a new field (json api notation) to the tree structure:
      #
      #   user_tree.notation
      #     #=> [:name, :surname, { subjects: [:title, { posts: { comments: :count } }], followers: :nickname }]
      #
      #   user_tree.merge!("subjects.posts.date").notation
      #     #=> [:name, :surname, { subjects: [:title, { posts: [{ comments: :count }, :date] }], followers: :nickname }]
      #
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
      
      # Return the tree structure in Rails includes notation including both associations and fields
      #
      #   user_tree.notation
      #     #=> [:name, :surname, { subjects: [:title, { posts: :comments }], followers: :nickname }]
      #
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

      # Return the tree structure in Rails includes notation including only associations
      #
      #   user_tree.notation
      #     #=> [{ subjects: { posts: :comments }}, :followers]
      #
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
        Array.wrap(to_includes).one? ? to_includes.first : to_includes
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
