class EventResponse < ActiveRecord::Base
    attr_accessible :event_id, :rsvp, :user_id

    belongs_to :user
    belongs_to :event
end
