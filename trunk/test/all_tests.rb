require 'test/unit/ui/console/testrunner'
require 'has_many_with_args_acceptance_test'

class AcceptanceTests

  def self.suite
    suite = Test::Unit::TestSuite.new('AcceptanceTests')
    suite << HasManyWithArgsAcceptanceTest.suite
    suite
  end

end

Test::Unit::UI::Console::TestRunner.run(AcceptanceTests)
