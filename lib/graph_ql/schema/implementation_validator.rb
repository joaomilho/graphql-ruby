# A helper to ensure `object` implements the concept `as`
class GraphQL::Schema::ImplementationValidator
  attr_reader :object, :errors, :implementation_as
  def initialize(object, as:, errors:)
    @object = object
    @implementation_as = as
    @errors = errors
  end

  # Ensure the object responds to `method_name`.
  # If `block_given?`, yield the return value of that method
  # If provided, use `as` in the error message, overriding class-level `as`.
  def must_respond_to(method_name, args: [], as: nil)
    if !object.respond_to?(method_name)
      local_as = as || implementation_as
      errors << "#{object.to_s} must respond to ##{method_name}(#{args.join(", ")}) to be a #{local_as}"
    elsif block_given?
      yield(object.public_send(method_name))
    end
  end
end
