require 'rails_helper'

describe Membership do
  describe '#num_charged_guests' do
    let(:membership_level) { create(:membership_level, num_free_guests: 5) }

    context 'when a membership has fewer guests than would be free for that membership level' do
      it 'returns 0' do
        expect(
          described_class.new(
            membership_level: membership_level,
            num_guests: membership_level.num_free_guests - 1
          ).num_charged_guests
        ).to equal(0)
      end
    end

    context 'when a membership has as many guests as would be free for that membership level' do
      it 'returns 0' do
        expect(
          described_class.new(
            membership_level: membership_level,
            num_guests: membership_level.num_free_guests
          ).num_charged_guests
        ).to equal(0)
      end
    end

    context 'when a membership has more guests than would be free for that membership level' do
      let(:difference) { 2 }

      it 'returns the difference between the number of guests and the number of free guests' do
        expect(
          described_class.new(
            membership_level: membership_level,
            num_guests: membership_level.num_free_guests + difference
          ).num_charged_guests
        ).to equal(difference)
      end
    end
  end
end
