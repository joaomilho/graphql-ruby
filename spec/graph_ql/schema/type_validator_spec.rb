require 'spec_helper'

describe GraphQL::Schema::TypeValidator do
  let(:base_type_defn) {
    {
      name: "InvalidType",
      description: "...",
      deprecation_reason: nil,
      kind: GraphQL::TypeKinds::OBJECT,
      interfaces: [],
      fields: {},
    }
  }
  let(:object) {
    o = OpenStruct.new(type_defn)
    def o.to_s; "InvalidType"; end
    o
  }
  let(:validator) { GraphQL::Schema::TypeValidator.new }
  let(:errors) { e = []; validator.validate(object, e); e;}
  describe 'when name isnt defined' do
    let(:type_defn) { base_type_defn.delete_if {|k,v| k == :name }}
    it 'requires name' do
      assert_equal(
        ["InvalidType must respond to #name() to be a Type"],
        errors
      )
    end
  end

  describe "when a field name isnt a string" do
    let(:type_defn) { base_type_defn.merge(fields: {symbol_field: (GraphQL::Field.new {|f|}) }) }
    it "requires string names" do
      assert_equal(
        ["InvalidType.fields keys must be Strings, but some aren't: symbol_field"],
        errors
      )
    end
  end

  describe "when a Union isnt valid" do
    let(:object) {
      GraphQL::Union.new("Something", "some union", [DairyProductInputType])
    }
    let(:errors) { e = []; GraphQL::Schema::TypeValidator.new.validate(object, e); e;}
    it 'must be 2+ types, must be only object types' do
      expected = [
        "Something.possible_types must be objects, but some aren't: <GraphQL::InputObjectType DairyProductInput>",
        "Union Something must be defined with 2 or more types, not 1",
      ]
      assert_equal(expected, errors)
    end
  end
end
