class GraphQL::NonNullType < GraphQL::ObjectType
  attr_reader :of_type
  def initialize(of_type:)
    @of_type = of_type
  end

  def name
    "Non-Null"
  end

  def coerce(value)
    of_type.coerce(value)
  end

  def kind
    GraphQL::TypeKinds::NON_NULL
  end

  def to_s
    "<GraphQL::NonNullType(#{of_type.name})>"
  end
end
