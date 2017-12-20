RSpec.describe Fields::Serializer do
  class A < ActiveRecord::Base
  end

  class C < ActionController::Base
  end

  it "has a version number" do
    expect(Fields::Serializer::VERSION).not_to be nil
  end

  it "extend models" do
    expect(A).to respond_to(:fields_to_includes)
    expect(A).to respond_to(:fields_serializer)
  end

  it "extend controllers" do
    expect(C.new).to respond_to(:render_json_fields)
  end

  it "define Fields::Serializer::FieldsTree" do
    expect { Fields::Serializer::FieldsTree }.not_to raise_exception
  end
end
