require "test/unit"
require "test/unit/testsuite"


runner = 
case (ARGV[0] || "").strip 
when "--console" 
  require "test/unit/ui/console/testrunner"
  Test::Unit::UI::Console::TestRunner
when "--fox"
  require 'test/unit/ui/fox/testrunner'
  Test::Unit::UI::Fox::TestRunner
when "--gtk"
  ENV['LC_NUMERIC'] = "en"
  require 'test/unit/ui/gtk/testrunner'
  Test::Unit::UI::GTK::TestRunner
when "--tk", ""
  # use Tk-Runner by default
  require 'test/unit/ui/tk/testrunner'
  Test::Unit::UI::Tk::TestRunner
end

$suite = Test::Unit::TestSuite.new

require "./test_syntax"
require "./test_datetime"
require "./test_parser"
require "./test_features"
require "./test_marshal"

runner.run($suite)
