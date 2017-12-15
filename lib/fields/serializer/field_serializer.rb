require "active_model_serializers"

# This is a generic serializer intended to return a subset of a model's attributes.
# It can be used with any model but does not currently support associations.
#
# Example usage:
#   render json: @region, serializer: FieldSerializer, fields: [:id, :title]
#
#   > { "id": "5f19582d-ee28-4e89-9e3a-edc42a8b59e5", "title": "London" }
#
class FieldSerializer < ActiveModel::Serializer
  def attributes(*args)
    fields = Array(args.first).map { |str| str.to_s.split(",").map(&:strip) }.flatten
    adding_id do
      merging_attributes do
        fields.map { |field| create_attribute_structure(field.split("."), object) }
      end
    end
  end

  private

  def adding_id(&block)
    block.call.merge(id: object.id)
  end

  def create_attribute_structure(attribute_stack, model)
    return unless model
    parent = attribute_stack.shift
    if attribute_stack.count > 0
      nested_model = model.send(parent)
      { parent => create_attribute_structure(attribute_stack, nested_model) }
    else
      { parent => model.send(parent) }
    end
  end

  def merging_attributes(&block)
    block.call.inject(:deep_merge!)
  end
end
