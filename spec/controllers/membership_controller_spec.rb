require 'rails_helper'

describe MembershipsController do
  describe 'POST create' do
    let(:customer_id) { 'customer_123' }
    let(:saved_customer_id) { 'saved_customer_123' }
    let(:subscription_id) { 'subscription_123' }

    before do
      allow(I18n).to receive(:t) { |*args| args }
      allow(Stripe::Customer).to receive(:create).and_return(double id: customer_id)
      allow(Stripe::Subscription).to receive(:create).and_return(double id: subscription_id)
    end

    context 'when no user is logged in' do
      it 'redirects to the login page' do
        post :create

        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when a user is logged in' do
      let!(:membership_level_1) { create :membership_level, usd_cost: 1000 }
      let!(:membership_level_2) { create :membership_level, usd_cost: 2000 }
      let!(:membership_level_3) { create :membership_level, usd_cost: 3000 }

      let(:gateway_customer) do
        build(
          :gateway_customer,
          customer_id: saved_customer_id,
          gateway: GatewayCustomer::GATEWAY.fetch(:stripe),
          deleted_at: nil
        )
      end
      let(:membership_level_with_active_subscription) { membership_level_2 }
      let(:membership_level_with_canceled_subscription) { membership_level_1 }
      let(:membership_level_with_no_subscription) { membership_level_3 }
      let(:membership_level) { membership_level_with_no_subscription }
      let(:level) { membership_level.name }
      let(:num_guests) { '7' }
      let(:stripe_email) { 'foo@example.com' }
      let(:stripe_token) { 'stripe_token_123' }
      let(:params) do
        {
          level: level,
          num_guests: num_guests,
          stripeEmail: stripe_email,
          stripeToken: stripe_token,
        }
      end

      log_in_user

      before do
        create(
          :membership,
          membership_level: membership_level_with_active_subscription,
          user: subject.current_user
        )
        create(
          :membership,
          membership_level: membership_level_with_canceled_subscription,
          user: subject.current_user,
          canceled_at: Time.current
        )

        subject.current_user.update!(gateway_customers: [
          build(
            :gateway_customer,
            gateway: GatewayCustomer::GATEWAY.fetch(:stripe),
            deleted_at: Time.current
          ),
          gateway_customer,
        ])
      end

      context 'when no `level` param is passed in' do
        it 'redirects to the membership purchase page with a flash error' do
          post :create, params: params.except(:level)

          expect(response).to redirect_to new_membership_path
          expect(subject.flash[:errors]).to match_array([
            ['membership.purchase_form.error.blank_level'],
          ])
        end
      end

      context 'when no `num_guests` param is passed in' do
        it 'redirects to the membership purchase page with a flash error' do
          post :create, params: params.except(:num_guests)

          expect(response).to redirect_to new_membership_path
          expect(subject.flash[:errors]).to match_array([
            ['membership.purchase_form.error.invalid_num_guests'],
          ])
        end
      end

      context 'when the `num_guests` param is set to less than 0' do
        let(:num_guests) { '-1' }

        it 'redirects to the membership purchase page with a flash error' do
          post :create, params: params

          expect(response).to redirect_to new_membership_path
          expect(subject.flash[:errors]).to match_array([
            ['membership.purchase_form.error.invalid_num_guests'],
          ])
        end
      end

      context 'when both `level` and `num_guests` are invalid' do
        let(:level) { '' }
        let(:num_guests) { '-1' }

        it 'redirects to the membership purchase page with flash errors' do
          post :create, params: params

          expect(response).to redirect_to new_membership_path
          expect(subject.flash[:errors]).to match_array([
            ['membership.purchase_form.error.blank_level'],
            ['membership.purchase_form.error.invalid_num_guests'],
          ])
        end
      end

      context 'when `level` does not match the name of an existing membership level' do
        let(:level) { 'foo' }

        it 'redirects to the membership purchase page with a flash error' do
          post :create, params: params

          expect(response).to redirect_to new_membership_path
          expect(subject.flash[:errors]).to match_array([
            ['membership.purchase_form.error.invalid_level'],
          ])
        end
      end

      context 'when `level` matches the name of a membership level that the user is actively subscribed to' do
        let(:level) { membership_level_with_active_subscription.name }

        it 'redirects to the membership purchase page with a flash error' do
          post :create, params: params

          expect(response).to redirect_to new_membership_path
          expect(subject.flash[:errors]).to match_array([
            [
              'membership.purchase_form.error.already_member', {
              level: ["membership.level.#{level}.name"],
            }],
          ])
        end
      end

      shared_examples_for 'a subscription is created' do
        context 'and the user has no active Stripe customer account' do
          let(:gateway_customer) do
            build(
              :gateway_customer,
              gateway: GatewayCustomer::GATEWAY.fetch(:stripe),
              deleted_at: Time.current
            )
          end

          it 'redirects to the user membership page with a flash notice' do
            post :create, params: params

            expect(response).to redirect_to memberships_path
            expect(subject.flash[:notice]).to match_array([
              'membership.purchase_form.success', { level: ["membership.level.#{level}.name"] },
            ])
          end

          it 'creates a Stripe customer' do
            expect(Stripe::Customer).to receive(:create).with(
              email: stripe_email,
              source: stripe_token,
            )

            post :create, params: params
          end

          it 'creates a Stripe subscription' do
            expect(Stripe::Subscription).to receive(:create).with(
              customer: customer_id,
              items: [{
                plan: membership_level.subscription_plan_id,
              }, {
                plan: membership_level.guest_subscription_plan_id,
                quantity: (membership_level.num_free_guests - num_guests.to_i).abs,
              }],
              trial_period_days: membership_level.num_trial_days
            )

            post :create, params: params
          end

          it 'creates a gateway customer record' do
            expect { post :create, params: params }.to change(GatewayCustomer, :count).by(1)

            expect(GatewayCustomer.last.attributes).to include({
              deleted_at: nil,
              customer_id: customer_id,
              gateway: GatewayCustomer::GATEWAY.fetch(:stripe),
              user_id: subject.current_user.id
            }.stringify_keys)
          end

          it 'creates a membership' do
            expect { post :create, params: params }.to change(Membership, :count).by(1)

            expect(Membership.last.attributes).to include({
              canceled_at: nil,
              gateway: GatewayCustomer::GATEWAY.fetch(:stripe),
              membership_level_id: membership_level.id,
              num_guests: num_guests.to_i,
              subscription_id: subscription_id,
              user_id: subject.current_user.id
            }.stringify_keys)
          end
        end

        context 'and the user has an active Stripe customer account' do
          it 'redirects to the user membership page with a flash notice' do
            post :create, params: params

            expect(response).to redirect_to memberships_path
            expect(subject.flash[:notice]).to match_array([
              'membership.purchase_form.success', { level: ["membership.level.#{level}.name"] },
            ])
          end

          it 'does not create a Stripe customer' do
            expect(Stripe::Customer).to_not receive(:create)

            post :create, params: params
          end

          it 'creates a Stripe subscription' do
            expect(Stripe::Subscription).to receive(:create).with(
              customer: saved_customer_id,
              items: [{
                plan: membership_level.subscription_plan_id,
              }, {
                plan: membership_level.guest_subscription_plan_id,
                quantity: (membership_level.num_free_guests - num_guests.to_i).abs,
              }],
              trial_period_days: membership_level.num_trial_days
            )

            post :create, params: params
          end

          it 'does not create a gateway customer record' do
            expect { post :create, params: params }.to_not change(GatewayCustomer, :count)
          end

          it 'creates a membership' do
            expect { post :create, params: params }.to change(Membership, :count).by(1)

            expect(Membership.last.attributes).to include({
              canceled_at: nil,
              gateway: GatewayCustomer::GATEWAY.fetch(:stripe),
              membership_level_id: membership_level.id,
              num_guests: num_guests.to_i,
              subscription_id: subscription_id,
              user_id: subject.current_user.id
            }.stringify_keys)
          end
        end
      end

      context 'when `level` matches the name of a membership level that the user has a canceled subscription to' do
        let(:membership_level) { membership_level_with_canceled_subscription }

        it_behaves_like 'a subscription is created'
      end

      context 'when `level` matches the name of a membership level that the user has no subscription to' do
        let(:membership_level) { membership_level_with_no_subscription }

        it_behaves_like 'a subscription is created'
      end

      context 'when a Stripe credit card error is raised' do
        let(:error_message) { 'This is an error.' }

        it 'redirects to the membership purchase page with a flash error' do
          allow(Stripe::Subscription).to receive(:create).and_raise(
            Stripe::CardError.new(error_message, nil, nil)
          )

          post :create, params: params

          expect(response).to redirect_to new_membership_path
          expect(subject.flash[:errors]).to match_array([error_message])
        end
      end

      context 'when an ActiveRecord error is raised' do
        let(:error) { ActiveRecord::ActiveRecordError.new }

        before do
          allow_any_instance_of(Membership).to receive(:save!).and_raise(error)
        end

        it 'redirects to the user membership page with a flash notice' do
          post :create, params: params

          expect(response).to redirect_to memberships_path
          expect(subject.flash[:notice]).to match_array([
            'membership.purchase_form.success', { level: ["membership.level.#{level}.name"] },
          ])
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(error)

          post :create, params: params
        end
      end
    end
  end

  describe 'GET new' do
    let!(:membership_level_1) { create :membership_level, usd_cost: 1000 }
    let!(:membership_level_2) { create :membership_level, usd_cost: 2000 }
    let!(:membership_level_3) { create :membership_level, usd_cost: 3000 }

    context 'when no user is logged in' do
      it 'redirects to the login page' do
        get :new

        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when a user is logged in' do
      let(:gateway_customers) { Array.new(2) { build :gateway_customer } }

      log_in_user

      before do
        subject.current_user.update!(gateway_customers: gateway_customers)
      end

      context 'and the user is subscribed to all membership levels' do
        it 'redirects to the user membership page' do
          [
            membership_level_1,
            membership_level_2,
            membership_level_3
          ].each do |membership_level|
            create :membership, membership_level: membership_level, user: subject.current_user
          end

          get :new

          expect(response).to redirect_to memberships_path
        end
      end

      context 'and the user is not subscribed to all membership levels' do
        let(:membership_level_with_active_subscription) { membership_level_1 }

        before do
          create(
            :membership,
            membership_level: membership_level_with_active_subscription,
            user: subject.current_user
          )
        end

        it 'renders the membership purchase page' do
          get :new

          expect(response).to render_template('memberships/new')
        end

        it 'sets a @gateway_customers variable' do
          get :new

          expect(assigns(:gateway_customers)).to match_array(gateway_customers)
        end

        context 'and a lowercase `level` param is passed in' do
          context 'and the param does not match the name of an existing membership level' do
            it 'sets the @prepopulated_level variable to nil' do
              get :new, params: { level: 'foo' }

              expect(assigns(:prepopulated_level)).to be_nil
            end
          end

          context 'and the param matches the name of a membership level that the user is subscribed to' do
            it 'sets the @prepopulated_level variable to nil' do
              get :new, params: { level: membership_level_1.name.downcase }

              expect(assigns(:prepopulated_level)).to be_nil
            end
          end

          context 'and the param matches the name of a membership level that the user is not subscribed to' do
            it 'sets the @prepopulated_level variable to the matching membership level' do
              get :new, params: { level: membership_level_2.name.downcase }

              expect(assigns(:prepopulated_level)).to eq(membership_level_2)
            end
          end
        end

        context 'and a mixed-case `level` param is passed in' do
          context 'and the param does not match the name of an existing membership level' do
            it 'sets the @prepopulated_level variable to nil' do
              get :new, params: { level: 'Foo' }

              expect(assigns(:prepopulated_level)).to be_nil
            end
          end

          context 'and the param matches the name of a membership level that the user is subscribed to' do
            it 'sets the @prepopulated_level variable to nil' do
              get :new, params: { level: membership_level_1.name.capitalize }

              expect(assigns(:prepopulated_level)).to be_nil
            end
          end

          context 'and the param matches the name of a membership level that the user is not subscribed to' do
            it 'sets the @prepopulated_level variable to the matching membership level' do
              get :new, params: { level: membership_level_2.name.capitalize }

              expect(assigns(:prepopulated_level)).to eq(membership_level_2)
            end
          end
        end
      end
    end
  end

  describe 'GET show' do
    let!(:membership_level_1) { create :membership_level, usd_cost: 1000 }
    let!(:membership_level_2) { create :membership_level, usd_cost: 3000 }
    let!(:membership_level_3) { create :membership_level, usd_cost: 2000 }

    context 'when no user is logged in' do
      it 'redirects to the login page' do
        get :show

        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when a user is logged in' do
      log_in_user

      it 'renders the user membership page' do
        get :show

        expect(response).to render_template('memberships/show')
      end

      it 'sets a @membership_levels variable' do
        get :show

        expect(assigns(:membership_levels)).to eq([
          membership_level_1,
          membership_level_3,
          membership_level_2,
        ])
      end
    end
  end
end
