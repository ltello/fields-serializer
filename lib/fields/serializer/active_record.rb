require 'active_record'
require "active_model_serializers"

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
        def fields_to_includes(*fields)
          fields_to_tree(fields).to_includes
        end

        def fields_serializer(*fields)
          create_serializer_class(fields_to_tree(fields).notation)
        end

        def create_serializer_class(fields)
          klass = self
          Class.new(ActiveModel::Serializer) do
            Array(fields).each do |field|
              if field.kind_of?(Hash)
                klass.nested_association(field)
              else
                attribute field.to_sym unless klass.association?(field)
              end
            end
          end
        end

        private

        def fields_to_tree(*fields)
          array_fields(fields.flatten).inject(FieldsTree.new(self), &:merge!)
        end

        # Calls:
        #   has_one :user, serializer: new_serializer_class_for_user_fields
        #     or
        #   belongs_to :user, serializer: new_serializer_class_for_user_fields
        #     or
        #   has_many :users, serializer: new_serializer_class_for_user_fields
        #
        def nested_association(fields)
          fields.each do |association_name, nested_fields|
            reflection = reflections[association_name]
            send(reflection.macro, association_name.to_sym, serializer: reflection.klass.create_serializer_class(nested_fields))
          end
        end

        def array_fields(fields)
          Array(fields).map { |str| str.to_s.split(",").map(&:strip) }.flatten.sort
        end

        def association?(key)
          reflections.keys.include?(key)
        end
      end
    end
  end
end
