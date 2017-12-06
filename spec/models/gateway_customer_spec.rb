require 'rails_helper'

describe GatewayCustomer do
  describe 'constants' do
    describe 'GATEWAY' do
      it 'contains payment gateway values' do
        expect(described_class::GATEWAY.fetch(:stripe)).to eq('stripe')
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect { create :gateway_customer }.to change(described_class, :count).by(1)
    end
  end

  describe 'relations' do
    describe 'user' do
      it 'has an associated user' do
        expect(create(:gateway_customer).user).to be_a(User)
      end
    end
  end

  describe 'scopes' do
    describe '.active' do
      context 'when there are only deleted customers' do
        it 'returns an empty result' do
          2.times { create :gateway_customer, deleted_at: Time.current }

          expect(described_class.active).to be_empty
        end
      end

      context 'when there are only non-deleted customers' do
        it 'returns only non-deleted customers' do
          active_customers = Array.new(2) { create :gateway_customer, deleted_at: nil }

          expect(described_class.active).to match(active_customers)
        end
      end

      context 'when there are both deleted and non-deleted customers' do
        it 'returns only non-deleted customers' do
          create :gateway_customer, deleted_at: Time.current
          active_customers = Array.new(2) { create :gateway_customer, deleted_at: nil }
          create :gateway_customer, deleted_at: Time.current

          expect(described_class.active).to match(active_customers)
        end
      end
    end
  end

  describe 'validations' do
    describe 'customer_id' do
      it 'validates for presence' do
        expect(build :gateway_customer, customer_id: nil).to_not be_valid
        expect(build :gateway_customer, customer_id: '').to_not be_valid
        expect(build :gateway_customer, customer_id: 'customer_123').to be_valid
      end

      it 'validates for maximum length' do
        expect(build :gateway_customer, customer_id: 'a' * 256).to_not be_valid
        expect(build :gateway_customer, customer_id: 'a' * 255).to be_valid
      end
    end

    describe 'gateway' do
      it 'validates for inclusion in a set of values' do
        expect(
          build :gateway_customer, gateway: GatewayCustomer::GATEWAY.fetch(:stripe)
        ).to be_valid
        expect(build :gateway_customer, gateway: 'foo').to_not be_valid
      end
    end

    describe 'user_id' do
      it 'validates that it is an existing user ID' do
        expect(build :gateway_customer, user_id: 1.5).to_not be_valid
        expect(build :gateway_customer, user_id: 1).to_not be_valid
        expect(build :gateway_customer, user_id: create(:user).id).to be_valid
      end
    end
  end
end
