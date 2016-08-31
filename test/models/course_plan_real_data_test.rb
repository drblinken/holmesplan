require 'test_helper'

class CoursePlanRealDataTest < ActiveSupport::TestCase
  @@testdatafile = File.expand_path(File.join(File.dirname(__FILE__), "testdata/timetableCalendar.json_15_.html"))
  noko_doc = Nokogiri::HTML(File.open(@@testdatafile))
  @@course_plan  = CoursePlan.new("",noko_doc)


  test "get next course id" do
    assert_equal "1473026400", @@course_plan.next_day_id
  end

  test "parse calendar" do
    events = @@course_plan.parse_calendar
    assert_equal 126, events.size
    assert events.any?{|e| e == Event.from_date_strings(label: "Hatha Yoga",
      start_time_string: "Wed, 31 Aug 2016 17:30:00 +0000",
      end_time_string: "Wed, 31 Aug 2016 18:45:00 +0000") }
    assert events.any?{|e| e == Event.from_date_strings(label: "Core Xpress",
      start_time_string: "Sun, 04 Sep 2016 17:00:00 +0000",
      end_time_string: "Sun, 04 Sep 2016 17:15:00 +0000") }
    assert events.any?{|e| e == Event.from_date_strings(label: "RÃ¼cken Fit ",
      start_time_string: "Mon, 29 Aug 2016 09:00:00 +0000",
      end_time_string: "Mon, 29 Aug 2016 09:50:00 +0000") }
      #puts events.inspect
  end

  test "all_course_labels" do
    courses = @@course_plan.all_course_labels
    assert_equal 39, courses.length
    assert courses.any? { |l | l == "Hatha Yoga"}
  end

end
