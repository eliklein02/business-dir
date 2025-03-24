class Business < ApplicationRecord
    validates :phone_number, presence: true, uniqueness: true
    geocoded_by :address, params: { countrycodes: "us" }
    before_save :set_address, :if => :new_record?
    before_save :geocode
    after_create :set_contact_url

    enum :business_type, { 
        :electrician=>0, 
        :plumber=>1, 
        :gardener=>2, 
        :painter=>3, 
        :graphic_artist=>4, 
        :handyman=>5, 
        :carpenter=>6, 
        :roofer=>7, 
        :mason=>8, 
        :welder=>9, 
        :hvac=>10, 
        :pest_control=>11, 
        :landscaper=>12, 
        :cleaning_service=>13 
    }
    enum :communication_form, { :whatsapp=>0, :sms=>1, :voice=>2 }

    def set_address
        self.address = "#{self.address}, #{self.city}, #{self.state} #{self.zip_code}"
    end

    def set_contact_url
        pn = self.phone_number
        if self.communication_form == "whatsapp"
            whatsapp_url = "https://api.whatsapp.com/send?phone=#{pn}&text=Hey,+I+heard+about+you+from+Business+Directory"
            new_url = HTTParty.get("https://tinyurl.com/api-create.php?url=#{whatsapp_url}").body
            self.update(contact_url: new_url)
        elsif self.communication_form == "sms"
            sms_url = "sms:#{pn}&Body=Hey,%20I%20heard%20about%20you%20from%20Business%20Directory"
            new_url = HTTParty.get("https://tinyurl.com/api-create.php?url=#{sms_url}").body
            self.update(contact_url: new_url)
        end
    end
end