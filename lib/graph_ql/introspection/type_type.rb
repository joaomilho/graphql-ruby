GraphQL::Introspection::TypeType = GraphQL::ObjectType.new do |t, type, field|
  t.name "__Type"
  t.description "A type in the GraphQL schema"

  t.fields = {
    name:           field.build(type: !type.String, desc: "The name of this type"),
    kind:           GraphQL::Field.new { |f|
                      f.type GraphQL::Introspection::TypeKindEnum
                      f.description "The kind of this type"
                      f.resolve -> (target, a, c) { target.kind.name }
                    },
    description:    field.build(type: type.String, desc: "The description for this type"),
    fields:         GraphQL::Introspection::FieldsField,
    ofType:         GraphQL::Introspection::OfTypeField,
    inputFields:    GraphQL::Introspection::InputFieldsField,
    possibleTypes:  GraphQL::Introspection::PossibleTypesField,
    enumValues:     GraphQL::Introspection::EnumValuesField,
    interfaces:     GraphQL::Introspection::InterfacesField,
  }
end
