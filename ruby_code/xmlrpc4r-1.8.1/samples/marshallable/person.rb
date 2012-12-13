
class Person 
  include XMLRPC::Marshallable
  attr_reader :name, :age

  def initialize(name, age)
    @name, @age = name, age
  end
end

