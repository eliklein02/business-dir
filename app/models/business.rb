class Business < ApplicationRecord
    has_secure_password
    validates :phone_number, presence: true
    geocoded_by :full_address, params: { countrycodes: "us" }
    before_save :set_full_address
    before_save :geocode
    before_save :add_one_to_phone_number
    after_commit :set_contact_url

    enum :business_type, {
        :electrician => 0,
        :plumber => 1,
        :gardener => 2,
        :painter => 3,
        :graphic_artist => 4,
        :handyman => 5,
        :carpenter => 6,
        :roofer => 7,
        :mason => 8,
        :welder => 9,
        :hvac => 10,
        :pest_control => 11,
        :landscaper => 12,
        :cleaning_service => 13
    }
    enum :communication_form, { :whatsapp=>0, :sms=>1, :voice=>2 }

    def set_full_address
        puts "startinf set_full_address"
        return unless self.address_changed? || self.city_changed? || self.state_changed? || self.zip_code_changed?
        puts "setting full address"
        address = self.address.split("#")[0]
        self.full_address = "#{address}, #{self.city}, #{self.state} #{self.zip_code}"
        puts "=============================="
        puts self.full_address
    end

    def set_contact_url
        puts "starting set_contact_url"
        return unless self.saved_change_to_phone_number?
        puts "setting contact url"
        root_url = ENV.fetch("ROOT_URL")
        pn = self.phone_number
        url = "#{root_url}/handle_click_and_redirect?pn=#{pn}&id=#{self.id}"
        new_url = HTTParty.get("https://tinyurl.com/api-create.php?url=#{url}").body
        self.update(contact_url: new_url)
    end

    def add_one_to_phone_number
        puts "atarting add_one_to_phone_number"
        pn = self.phone_number
        pn_numbers_only = pn.gsub!(/[^0-9]/, '')
        self.phone_number = pn if pn.length == 11
        self.phone_number = "1#{pn}" if pn.length == 10
    end
end
