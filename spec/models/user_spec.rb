require 'rails_helper'

describe User do
  describe 'factory' do
    it 'has a valid factory' do
      expect { create :user }.to change(described_class, :count).by(1)
    end
  end

  describe 'relations' do
    let(:user) { create :user }

    describe 'gateway_customers' do
      it 'has associated gateway customers' do
        create :gateway_customer
        gateway_customers = Array.new(2) { create :gateway_customer, user: user }
        create :gateway_customer

        expect(user.gateway_customers).to match(gateway_customers)
      end
    end

    describe 'memberships' do
      it 'has associated memberships' do
        create :membership
        memberships = Array.new(2) { create :membership, user: user }
        create :membership

        expect(user.memberships).to match(memberships)
      end
    end

    describe 'membership_levels' do
      it 'has associated membership levels' do
        create :membership_level
        membership_levels = Array.new(2) { create :membership_level }
        membership_levels.each do |membership_level|
          create :membership, membership_level: membership_level, user: user
        end
        create :membership_level

        expect(user.membership_levels).to match(membership_levels)
      end
    end
  end

  describe '#member?' do
    context 'when the user has no memberships' do
      it 'returns false' do
        expect(create(:user, memberships: []).member?).to be(false)
      end
    end

    context 'when the user has only canceled memberships' do
      it 'returns false' do
        expect(create(:user, memberships: [
          build(:membership, canceled_at: Time.current),
          build(:membership, canceled_at: Time.current),
        ]).member?).to be(false)
      end
    end

    context 'when the user has only non-canceled memberships' do
      it 'returns true' do
        expect(create(:user, memberships: [
          build(:membership, canceled_at: nil),
          build(:membership, canceled_at: nil),
        ]).member?).to be(true)
      end

    end

    context 'when the user has both canceled and non-canceled memberships' do
      it 'returns true' do
        expect(create(:user, memberships: [
          build(:membership, canceled_at: Time.current),
          build(:membership, canceled_at: nil),
          build(:membership, canceled_at: Time.current),
        ]).member?).to be(true)
      end
    end
  end

  describe 'membership_for' do
    let(:membership_level_name) { 'membership_level_123' }
    let(:membership_level) { create :membership_level, name: membership_level_name }
    let(:membership) { build :membership, membership_level: membership_level, canceled_at: nil }

    context 'when the user has no membership for the given membership level' do
      it 'returns nil' do
        expect(
          create(
            :user,
            memberships: [
              build(:membership, membership_level: create(:membership_level), canceled_at: nil),
            ]
          ).membership_for(membership_level_name)
        ).to be_nil
      end
    end

    context 'when the user has only canceled memberships for the given membership level' do
      it 'returns nil' do
        expect(
          create(
            :user,
            memberships: Array.new(2) do
              build :membership, membership_level: membership_level, canceled_at: Time.current
            end
          ).membership_for(membership_level_name)
        ).to be_nil
      end
    end

    context 'when the user has only a non-canceled membership for the given membership level' do
      it "returns the user's non-canceled membership for the given membership level" do
        expect(
          create(
            :user,
            memberships: [
              build(:membership, membership_level: create(:membership_level), canceled_at: nil),
              membership,
            ]
          ).membership_for(membership_level_name)
        ).to eq(membership)
      end
    end

    context 'when the user has both canceled and non-canceled memberships for the given membership level' do
      it "returns the user's non-canceled membership for the given membership level" do
        expect(
          create(
            :user,
            memberships: [
              build(:membership, membership_level: membership_level, canceled_at: Time.current),
              membership,
              build(:membership, membership_level: membership_level, canceled_at: Time.current),
            ]
          ).membership_for(membership_level_name)
        ).to eq(membership)
      end
    end
  end

  describe '#stripe_customer' do
    let(:gateway_customer) do
      build :gateway_customer, gateway: GatewayCustomer::GATEWAY.fetch(:stripe), deleted_at: nil
    end

    context 'when the user has no Stripe customer account' do
      it 'returns nil' do
        expect(create(:user, gateway_customers: []).stripe_customer).to be_nil
      end
    end

    context 'when the user has only deleted Stripe customer accounts' do
      it 'returns nil' do
        expect(
          create(
            :user,
            gateway_customers: Array.new(2) do
              build(
                :gateway_customer,
                gateway: GatewayCustomer::GATEWAY.fetch(:stripe),
                deleted_at: Time.current
              )
            end
          ).stripe_customer
        ).to be_nil
      end
    end

    context 'when the user has only a non-deleted Stripe customer account' do
      it "returns the user's non-deleted Stripe customer record" do
        expect(
          create(:user, gateway_customers: [gateway_customer]).stripe_customer
        ).to eq(gateway_customer)
      end
    end

    context 'when the user has both deleted and non-deleted Stripe customer accounts' do
      it "returns the user's non-deleted Stripe customer record" do
        expect(
          create(:user, gateway_customers: [
            build(
              :gateway_customer,
              gateway: GatewayCustomer::GATEWAY.fetch(:stripe),
              deleted_at: Time.current
            ),
            gateway_customer,
            build(
              :gateway_customer,
              gateway: GatewayCustomer::GATEWAY.fetch(:stripe),
              deleted_at: Time.current
            ),
          ]).stripe_customer
        ).to eq(gateway_customer)
      end
    end
  end
end
