require 'test_helper'
class HolmesCoursePlan  < Minitest::Test
  def setup
    @course_plan = CoursePlan.new
  end

  def test_next_day_id
    assert_match /\d{10}/,@course_plan.next_day_id
  end
end
