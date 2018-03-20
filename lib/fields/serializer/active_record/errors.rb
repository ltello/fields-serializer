module Fields
  module Serializer
    module ActiveRecord

      module Errors
        # Return a hash with errors of the model merged with errors of the given associated models.
        #
        #   {
        #     name: ["can't be blank"],
        #     age:  ["must be greater than 18"],
        #     cars: {
        #       "xxx-xxxxxxxx-xxx-xxxxxx" => {
        #         make: ["can't be blank"],
        #         type: ["can't be blank"]
        #       },
        #       "0" => {
        #         make: ["can't be blank"],
        #         year: ["must be greater than 1800"]
        #       }
        #       "1" => {
        #         year: ["must be greater than 1800"]
        #       }
        #     }
        #   }
        #
        #   where "xxx-xxxxxxxx-xxx-xxxxxx" is the id of an associated model and
        #         an incremental integer id is given to those associated models with empty id.
        #         Similar to ActiveRecord nested attributes notation.
        def deep_errors(*association_keys)
          association_keys.inject(errors.to_h) do |error_tree, association_key|
            associate = send(association_key)
            associate = associate.to_a if self.class.reflections[association_key.to_s].collection?
            error_tree.merge!(association_key => __associate_errors(associate))
          end
        end

        private

        # For single asssociated instance (has_one association):
        #   { name: ["can't be blank"], age: ["can't be less than 18"] }
        #
        # For multiple asssociated instances (has_many association):
        #   {  "xxx-xxxxxxxx-xxx-xxxxxx" => { name: ["can't be blank"], age: ["can't be less than 18"] },
        #                            "0" => { name: ["can't be blank"], age: ["can't be less than 18"] },
        def __associate_errors(associate)
          if associate.kind_of?(Array)
            associate.to_a.map.with_index { |object, i| [object.id || i, object.errors.to_h] }.to_h
          else
            associate.errors.to_h
          end
        end
      end
    end
  end
end
