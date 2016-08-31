require 'test_helper'
class HolmesCoursePlan  < Minitest::Test
  def setup
    @course_plan = CoursePlan.new
  end

  def test_next_day_id
    assert_match /\d{10}/,@course_plan.next_day_id
  end

  def test_date_header
    date_header = @course_plan.date_header
    assert_equal Nokogiri::XML::NodeSet,date_header.class
    assert_equal 7, date_header.size
    assert_match /\d\d? August/,@course_plan.select_date(date_header[0])
  end
  def test_all_courses
    
  end

end
