require 'test_helper'
class HolmesCoursePlan  < Minitest::Test

  def test_something
    course_plan = CoursePlan.new
    elements = course_plan.doc.css("div.headerNextDay")
    assert_equal "asdf", elements.class
  end

end
