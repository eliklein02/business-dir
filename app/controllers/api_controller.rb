class ApiController < ApplicationController
    # skip_before_action :verify_authenticity_token
    VERIFY_TOKEN = "it_is_a_whatsapp_bot"

    def whatsapp_webhook
        if request.get?
            if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == VERIFY_TOKEN
                render plain: params["hub.challenge"], status: :ok
            else
                render plain: "Verification token mismatch", status: :forbidden
            end
        elsif request.post?
            entry = params["entry"]&.first
            changes = entry["changes"]&.first if entry
            value = changes["value"] if changes
            messages = value["messages"]&.first if value
            statuses = value["statuses"]&.first if value

            if messages
                sender = messages["from"]
                message = messages["text"]["body"]
                puts "Sender: #{sender} said: #{message}"
                send_whatsapp_message(sender, "You said: #{message}")
                render json: { message: "Message sent" }, status: :ok
            elsif statuses
                puts "Statuses: #{statuses["status"]}"
                render json: { message: "Status received" }, status: :ok
            else
                puts "weird phenomenon"
                render json: { message: "Unknown data received" }, status: :unprocessable_entity
            end
        else
            render json: { message: "Unsupported request method" }, status: :method_not_allowed
        end
    end

    def send_whatsapp_message(recipient, message)
        client = WhatsappSdk::Api::Client.new
        client.messages.send_text(sender_id: ENV.fetch("PHONE_NUMBER_ID"), recipient_number: recipient, message: message)
    end
end
