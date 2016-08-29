require 'test_helper'

class WeekControllerTest < ActionDispatch::IntegrationTest
  test "should get courses" do
    get week_courses_url
    assert_response :success
  end

end
