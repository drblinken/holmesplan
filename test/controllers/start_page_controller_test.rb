require 'test_helper'

class StartPageControllerTest < ActionDispatch::IntegrationTest
  test "should get select" do
    get start_page_select_url
    assert_response :success
  end

end
