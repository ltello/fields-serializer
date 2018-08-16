require "active_record"
require "active_model_serializers"
require_relative "active_record/errors"

module Fields
  module Serializer
    module ActiveRecord
      extend ActiveSupport::Concern
      include Errors

      class_methods do
        # If key is an association of a given model class
        def association?(key)
          reflections.key?(key.to_s)
        end

        # Convert a list of fields (json_api notation) in a list of associations to be
        # added to a ActiveRecord Model.includes call
        #
        # Example:
        #
        #  BoilerPack.fields_to_includes("id,boiler.gas_safe_code") #=> ["boiler"]
        #
        def fields_to_includes(*fields)
          fields_to_tree(fields).to_includes
        end

        # Creates new anonymous ActiveModel::Serializer subclass from fields in json api notation:
        #
        # Class.new do
        #   attribute :id
        #   attribute :non_association_field_1
        #   attribute :non_association_field_2
        #   attribute :non_association_field_3
        #   attribute :non_association_field_4
        #               ...
        #
        #   has_one    :association_field_1, serializer: new_serializer_class_for_association_field_1_nested_fields
        #     or
        #   belongs_to :association_field_2, serializer: new_serializer_class_for_association_field_2_nested_fields
        #     or
        #   has_many   :association_field_3, serializer: new_serializer_class_for_association_field_3_nested_fields
        # end              ...
        def fields_serializer(*fields)
          create_serializer_class(fields_to_tree(fields).notation)
        end

        # Creates new anonymous ActiveModel::Serializer subclass from fields in Rails includes notation
        def create_serializer_class(fields)
          klass = self
          Class.new(ActiveModel::Serializer).tap do |new_class|
            new_class.class_eval do
              attribute :id
              Array.wrap(fields).each do |field|
                if field.kind_of?(Hash)
                  field.each do |association_name, nested_fields|
                    reflection = klass.reflections[association_name]
                    send(reflection.macro, association_name.to_sym, serializer: reflection.klass.create_serializer_class(nested_fields))
                  end
                else
                  attribute field.to_sym unless klass.association?(field)
                end
              end
            end
          end
        end

        private

        def fields_to_tree(*fields)
          array_fields(fields.flatten).inject(FieldsTree.new(self), &:merge!)
        end

        def array_fields(fields)
          Array.wrap(fields).map { |str| str.to_s.split(",").map(&:strip) }.flatten.sort
        end
      end
    end
  end
end
