require 'test_helper'

class UpdateTermJobTest < ActiveJob::TestCase
  test "test term updated" do
    @term = terms(:sixteenspring)
    UpdateTerm.perform_now(@term)
    assert_not @term.updating
  end
end
