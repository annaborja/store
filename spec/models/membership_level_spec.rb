require 'rails_helper'

describe MembershipLevel do
  describe 'factory' do
    it 'has a valid factory' do
      expect { create :membership_level }.to change(described_class, :count).by(1)
    end
  end

  describe 'relations' do
    describe 'memberships' do
      let(:membership_level) { create :membership_level }

      it 'has associated memberships' do
        create :membership
        memberships = Array.new(2) { create :membership, membership_level: membership_level }
        create :membership

        expect(membership_level.memberships).to match(memberships)
      end
    end
  end
end
