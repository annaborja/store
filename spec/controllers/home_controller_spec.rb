require 'rails_helper'

describe HomeController do
  describe 'GET index' do
    it 'renders the home page' do
      get :index

      expect(response).to render_template('home/index')
    end
  end
end
