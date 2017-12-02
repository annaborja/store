require 'test_helper'

class AccountControllerTest < ActionDispatch::IntegrationTest
  test "should get membership" do
    get account_membership_url
    assert_response :success
  end

end
