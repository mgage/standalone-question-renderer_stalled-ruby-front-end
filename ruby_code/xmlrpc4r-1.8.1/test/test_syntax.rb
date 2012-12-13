require "test/unit"

class Test_Syntax < Test::Unit::TestCase
  def test_syntax
    assert(`find .. -name "*.rb" -exec ruby -c {} \; | grep -v "OK"`.strip.empty?, "Syntax error")
  end
end

if $suite != nil
  $suite << Test_Syntax.suite
else
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(Test_Syntax)
end
