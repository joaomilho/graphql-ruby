require 'spec_helper'

describe GraphQL::Introspection::TypeType do
  let(:query_string) {%|
     query introspectionQuery {
       cheeseType:    __type(name: "Cheese") { name, kind, fields { name, isDeprecated, type { name, ofType { name } } } }
       milkType:      __type(name: "Milk") { interfaces { name }, fields { type { name, ofType { name } } } }
       dairyAnimal:   __type(name: "DairyAnimal") { name, kind, enumValues(includeDeprecated: false) { name, isDeprecated } }
       dairyProduct:  __type(name: "DairyProduct") { name, kind, possibleTypes { name } }
       animalProduct: __type(name: "AnimalProduct") { name, kind, possibleTypes { name }, fields { name } }
     }
  |}
  let(:query) { GraphQL::Query.new(DummySchema, query_string, context: {}, params: {"cheeseId" => 2})}
  let(:cheese_fields) {[
    {"name"=>"id",          "isDeprecated" => false, "type" => { "name" => "Non-Null", "ofType" => { "name" => "Int"}}},
    {"name"=>"flavor",      "isDeprecated" => false, "type" => { "name" => "Non-Null", "ofType" => { "name" => "String"}}},
    {"name"=>"source",      "isDeprecated" => false, "type" => { "name" => "Non-Null", "ofType" => { "name" => "DairyAnimal"}}},
    {"name"=>"similarCheeses", "isDeprecated"=>false, "type"=>{"name"=>"Cheese", "ofType"=>nil}},
    {"name"=>"__typename",  "isDeprecated"=>false,    "type"=> { "name" => "Non-Null", "ofType" => { "name" => "String"}}},
  ]}

  let(:dairy_animals) {[
    {"name"=>"COW",   "isDeprecated"=> false },
    {"name"=>"GOAT",  "isDeprecated"=> false },
    {"name"=>"SHEEP", "isDeprecated"=> false },
  ]}
  it 'exposes metadata about types' do
    expected = {"data"=> { "introspectionQuery" => {
      "cheeseType" => {
        "name"=> "Cheese",
        "kind" => "OBJECT",
        "fields"=> cheese_fields
      },
      "milkType"=>{
        "interfaces"=>[
          {"name"=>"Edible"},
          {"name"=>"AnimalProduct"}
        ],
        "fields"=>[
          {"type"=>{"name"=>"Non-Null", "ofType"=>{"name"=>"Int"}}},
          {"type"=>{"name"=>"DairyAnimal", "ofType"=>nil}},
          {"type"=>{"name"=>"Non-Null", "ofType"=>{"name"=>"Float"}}},
          {"type"=>{"name"=>"List", "ofType"=>{"name"=>"String"}}},
          {"type"=>{"name"=>"Non-Null", "ofType"=>{"name"=>"String"}}}
        ]
      },
      "dairyAnimal"=>{
        "name"=>"DairyAnimal",
        "kind"=>"ENUM",
        "enumValues"=> dairy_animals,
      },
      "dairyProduct"=>{
        "name"=>"DairyProduct",
        "kind"=>"UNION",
        "possibleTypes"=>[{"name"=>"Milk"}, {"name"=>"Cheese"}],
      },
      "animalProduct" => {
        "name"=>"AnimalProduct",
        "kind"=>"INTERFACE",
        "possibleTypes"=>[{"name"=>"Cheese"}, {"name"=>"Milk"}],
        "fields"=>[
          {"name"=>"source"},
          {"name"=>"__typename"},
        ]
      }
    }}}
    assert_equal(expected, query.result)
  end

  describe 'deprecated fields' do
    let(:query_string) {%|
       query introspectionQuery {
         cheeseType:    __type(name: "Cheese") { name, kind, fields(includeDeprecated: true) { name, isDeprecated, type { name, ofType { name } } } }
         dairyAnimal:   __type(name: "DairyAnimal") { name, kind, enumValues(includeDeprecated: true) { name, isDeprecated } }
       }
    |}
    let(:deprecated_fields) { {"name"=>"fatContent", "isDeprecated"=>true, "type"=>{"name"=>"Non-Null", "ofType"=>{"name"=>"Float"}}} }
    it 'can expose deprecated fields' do
      typename = cheese_fields.pop
      new_cheese_fields = cheese_fields + [deprecated_fields, typename]
      expected = { "data" => { "introspectionQuery" => {
        "cheeseType" => {
          "name"=> "Cheese",
          "kind" => "OBJECT",
          "fields"=> new_cheese_fields
        },
        "dairyAnimal"=>{
          "name"=>"DairyAnimal",
          "kind"=>"ENUM",
          "enumValues"=> dairy_animals + [{"name" => "YAK", "isDeprecated" => true}],
        },
      }}}
      assert_equal(expected, query.result)
    end

    describe 'input objects' do
      let(:query_string) {%|
         query introspectionQuery {
           __type(name: "DairyProductInput") { name, description, kind, inputFields { name, type { name }, defaultValue } }
         }
      |}

      it 'exposes metadata about input objects' do
        expected = { "data" => { "introspectionQuery" => {
            "__type" => {
              "name"=>"DairyProductInput",
              "description"=>"Properties for finding a dairy product",
              "kind"=>"INPUT_OBJECT",
              "inputFields"=>[
                {"name"=>"source", "type"=>{ "name" => "DairyAnimal"}, "defaultValue"=>nil},
                {"name"=>"fatContent", "type"=>{ "name" => "Float"}, "defaultValue"=>nil}
              ]
            }
          }}}
        assert_equal(expected, query.result)
      end
    end
  end
end
