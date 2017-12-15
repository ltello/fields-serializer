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
    return model unless model.present?
    parent = attribute_stack.shift
    if attribute_stack.count > 0
      if model.kind_of?(Array)
        collection_attribute_structure(model, attribute_stack, parent)
      else
        attribute_structure(model, attribute_stack, parent)
      end
    else
      value_structure(model, parent)
    end
  end

  def attribute_structure(model, attribute_stack, parent)
    { parent => create_attribute_structure(attribute_stack, model.send(parent)) }
  end

  def collection_attribute_structure(models, attribute_stack, parent)
    models.map { |model| attribute_structure(model, attribute_stack, parent) }
  end

  def merging_attributes(&block)
    block.call.inject(:deep_merge!)
  end

  def value_structure(model, attribute_name)
    { attribute_name => model.send(attribute_name) }
  end
end
