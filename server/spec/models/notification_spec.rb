require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:event_type) }
    it { should validate_inclusion_of(:event_type).in_array(['like', 'comment', 'follow', 'mention']) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:notifiable) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:read_notification) do
      create(:notification, user: user, event_type: 'like', notifiable: create(:like)).tap do |n|
        n.update(read_at: Time.current)
      end
    end
    let!(:unread_notification) do
      create(:notification, user: user, event_type: 'comment', notifiable: create(:comment))
    end

    it 'returns only unread notifications' do
      expect(Notification.unread).to include(unread_notification)
      expect(Notification.unread).not_to include(read_notification)
    end

    it 'returns only read notifications' do
      expect(Notification.read).to include(read_notification)
      expect(Notification.read).not_to include(unread_notification)
    end

    it 'orders by recent' do
      older = create(:notification, user: user, event_type: 'like', notifiable: create(:like), created_at: 2.days.ago)
      newer = create(:notification, user: user, event_type: 'like', notifiable: create(:like), created_at: 1.day.ago)
      expect(Notification.recent.first).to eq(newer)
    end
  end

  describe 'instance methods' do
    let(:notification) { create(:notification, user: create(:user), event_type: 'like', notifiable: create(:like)) }

    describe '#read?' do
      it 'returns false for unread notification' do
        expect(notification.read?).to be false
      end

      it 'returns true for read notification' do
        notification.update(read_at: Time.current)
        expect(notification.read?).to be true
      end
    end

    describe '#mark_as_read!' do
      it 'marks notification as read' do
        expect {
          notification.mark_as_read!
        }.to change { notification.reload.read? }.from(false).to(true)
      end
    end

    describe '#mark_as_unread!' do
      it 'marks notification as unread' do
        notification.update(read_at: Time.current)
        expect {
          notification.mark_as_unread!
        }.to change { notification.reload.read? }.from(true).to(false)
      end
    end
  end
end
