class PagesController < ApplicationController
    def index
    end

    def contact
    end

    def save_contact
        Event.create(event_type: :contact_save)
        vcard = <<~VCARD
            BEGIN:VCARD
            VERSION:3.0
            FN:Eli
            TEL:+12124441119
            END:VCARD
        VCARD

        send_data vcard, filename: "contact.vcf", type: "text/vcf"
    end

    def about
    end

    def privacy_policy
    end

    def admin
        protect_route
    end

    private
end
