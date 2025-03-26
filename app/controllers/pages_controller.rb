class PagesController < ApplicationController
    def index
        if current_business
            redirect_to business_path(current_business)
        else
            render :index
        end
    end

    def contact
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

    def dashboard
        protect_route
    end

    private
end
