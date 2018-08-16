require "active_support"
require "active_support/core_ext"
require "active_support/concern"
require "fields/serializer/version"
require "fields/serializer/active_record"
require "fields/serializer/action_controller"
require "fields/serializer/fields_tree"

module Fields
  module Serializer
    ActiveSupport.on_load(:active_record) do
      include Fields::Serializer::ActiveRecord
    end

    ActiveSupport.on_load(:action_controller) do
      include Fields::Serializer::ActionController
    end
  end
end
