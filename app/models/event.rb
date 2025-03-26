class Event < ApplicationRecord
    enum :event_type, { :click => 0 }
end
