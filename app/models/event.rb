class Event < ApplicationRecord
    enum :event_type, { :click => 0, :view => 1, :contact_save => 2 }
end
