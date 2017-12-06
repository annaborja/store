require 'rails_helper'

describe Membership do
  describe 'factory' do
    it 'has a valid factory' do
      expect { create :membership }.to change(described_class, :count).by(1)
    end
  end

  describe 'relations' do
    describe 'membership_level' do
      it 'has an associated membership level' do
        expect(create(:membership).membership_level).to be_a(MembershipLevel)
      end
    end

    describe 'user' do
      it 'has an associated user' do
        expect(create(:membership).user).to be_a(User)
      end
    end
  end

  describe 'scopes' do
    describe '.active' do
      context 'when there are only canceled memberships' do
        it 'returns an empty result' do
          2.times { create :membership, canceled_at: Time.current }

          expect(described_class.active).to be_empty
        end
      end

      context 'when there are only non-canceled memberships' do
        it 'returns only non-canceled memberships' do
          active_memberships = Array.new(2) { create :membership, canceled_at: nil }

          expect(described_class.active).to match_array(active_memberships)
        end
      end

      context 'when there are both canceled and non-canceled memberships' do
        it 'returns only non-canceled memberships' do
          create :membership, canceled_at: Time.current
          active_memberships = Array.new(2) { create :membership, canceled_at: nil }
          create :membership, canceled_at: Time.current

          expect(described_class.active).to match_array(active_memberships)
        end
      end
    end
  end

  describe 'validations' do
    describe 'membership_level_id' do
      it 'validates that it is an existing membership level ID' do
        expect(build(:membership, membership_level_id: 1.5)).to_not be_valid
        expect(build(:membership, membership_level_id: 1)).to_not be_valid
        expect(build(:membership, membership_level_id: create(:membership_level).id)).to be_valid
      end
    end

    describe 'num_guests' do
      it 'validates that it is an integer' do
        expect(build(:membership, num_guests: 1.5)).to_not be_valid
        expect(build(:membership, num_guests: 1)).to be_valid
      end

      it 'validates that the number is greater than or equal to 0' do
        expect(build(:membership, num_guests: -2)).to_not be_valid
        expect(build(:membership, num_guests: 0)).to be_valid
        expect(build(:membership, num_guests: 2)).to be_valid
      end
    end

    describe 'user_id' do
      it 'validates that it is an existing user ID' do
        expect(build(:membership, user_id: 1.5)).to_not be_valid
        expect(build(:membership, user_id: 1)).to_not be_valid
        expect(build(:membership, user_id: create(:user).id)).to be_valid
      end
    end
  end

  describe '#num_charged_guests' do
    let(:num_free_guests) { 5 }
    let(:membership_level) { create :membership_level, num_free_guests: num_free_guests }
    let(:membership) { described_class.new(membership_level: membership_level) }

    context 'when a membership has fewer guests than would be free for that membership level' do
      it 'returns 0' do
        membership.num_guests = num_free_guests - 1

        expect(membership.num_charged_guests).to equal(0)
      end
    end

    context 'when a membership has as many guests as would be free for that membership level' do
      it 'returns 0' do
        membership.num_guests = num_free_guests

        expect(membership.num_charged_guests).to equal(0)
      end
    end

    context 'when a membership has more guests than would be free for that membership level' do
      let(:difference) { 3 }

      it 'returns the difference between the number of guests and the number of free guests' do
        membership.num_guests = num_free_guests + difference

        expect(membership.num_charged_guests).to equal(difference)
      end
    end
  end

  describe '#usd_cost' do
    let(:membership) do
      described_class.new(
        membership_level: create(:membership_level, additional_guest_usd_cost: 1010, usd_cost: 1337)
      )
    end

    before do
      allow(membership).to receive(:num_charged_guests).and_return(num_charged_guests)
    end

    context 'when there are no charged guests' do
      let(:num_charged_guests) { 0 }

      it 'returns the base membership level cost' do
        expect(membership.usd_cost).to equal(1337)
      end
    end

    context 'when there is one charged guest' do
      let(:num_charged_guests) { 1 }

      it 'returns the base membership level cost plus the additional guest cost' do
        expect(membership.usd_cost).to equal(2347)
      end
    end

    context 'when there are multiple charged guests' do
      let(:num_charged_guests) { 3 }

      it 'returns the base membership level cost plus the additional guest cost for each charged guest' do
        expect(membership.usd_cost).to equal(4367)
      end
    end
  end
end
