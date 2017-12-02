require 'test_helper'

class AccountControllerTest < ActionDispatch::IntegrationTest
  test "should get subscription" do
    get account_subscription_url
    assert_response :success
  end

end
