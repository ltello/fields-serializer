require "active_record"
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

      # Self if any fields or associations. Nil otherwise
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
        return self if join_field.blank?
        parent, rest = join_field.to_s.split(".", 2)
        rest.present? ? add_association!(parent, rest) : add_field!(parent)
        self
      end

      # Return the tree structure in Rails includes notation including both associations and fields
      #
      #   user_tree.notation
      #     #=> [:name, :surname, { subjects: [:title, { posts: :comments }], followers: :nickname }]
      #
      def notation
        return associations_to_notation.presence if fields.blank?
        if associations.present?
          fields.dup << associations_to_notation
        else
          fields.one? ? fields.first.dup : fields.dup
        end
      end

      # Return the tree structure in Rails includes notation including only associations
      #
      #   user_tree.notation
      #     #=> [{ subjects: { posts: :comments }}, :followers]
      #
      def to_includes
        to_includes = associations.inject([]) do |result, (association_name, association_tree)|
          association_includes = association_tree.to_includes
          if association_includes.present?
            add_association_includes_to_includes!(result, association_name, association_includes)
          else
            add_association_to_includes!(result, association_name)
          end
        end.presence
        Array.wrap(to_includes).one? ? to_includes.first : to_includes
      end

      def to_s
        notation.to_s
      end

      private

      def add_association!(parent, rest)
        existing_association?(parent) ? merge_association!(parent, rest) : append_association!(parent, rest)
      end

      def add_association_includes_to_includes!(includes, association_name, association_includes)
        new_has_entry = { association_name => association_includes }
        includes_hash = includes.find { |e| e.is_a?(Hash) }
        includes_hash ? includes_hash.merge!(new_has_entry) : (includes << new_has_entry)
        includes
      end

      def add_association_to_includes!(includes, association_name)
        includes << association_name
      end

      def append_association!(parent, rest)
        if association?(parent)
          nested_class       = klass.reflections[parent].klass
          nested_fields_tree = FieldsTree.new(nested_class).merge!(rest).presence
          new_association    = { parent => nested_fields_tree } if nested_fields_tree
          associations.merge!(new_association) if new_association
        end
      end

      def add_field!(value)
        fields << value if new_field?(value)
      end

      def association?(value)
        klass.reflections.key?(value)
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

      def merge_association!(key, fields)
        associations[key].merge!(fields)
      end

      def new_field?(value)
        !existing_field?(value) && !association?(value)
      end
    end
  end
end
