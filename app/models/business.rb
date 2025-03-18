class Business < ApplicationRecord
    geocoded_by :address, params: { countrycodes: "us" }
    before_save :geocode

    enum :business_type, { :electrician=>0, :plumber=>1, :gardener=>2, :painter=>3, :graphic_artist=>4 }

    enum :communication_form, { :whatsapp=>0, :sms=>1, :voice=>2 }
end