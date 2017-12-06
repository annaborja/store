module ControllerMacros
  def log_in_user
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      sign_in create(:user)
    end
  end
end
