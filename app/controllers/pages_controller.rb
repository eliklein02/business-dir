class PagesController < ApplicationController
    def index
    end

    def save_contact
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

    private
end
