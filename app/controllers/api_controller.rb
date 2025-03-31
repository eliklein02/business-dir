class ApiController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :whatsapp_webhook, if: -> { request.post? }
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
                return if messages["type"] == "reaction" || messages["type"] == "sticker"
                sender = messages["from"]
                message = messages["text"]["body"]
                first_word = message.split(" ").first.downcase
                case first_word
                when "hi", "hello", "hey"
                    send_whatsapp_message(sender, "👋 *Welcome to Business Directory!*\n\nUse this bot to find local businesses. For example, 'plumber brooklyn ny', or 'electrician in 08527' \n\n _You can always reply 'help' for instructions._ ")
                    render json: { message: "Message sent" }, status: :ok
                when "help"
                    send_whatsapp_message(sender, "Hey there! 👋 Need some help finding a service?\n\nHere's how to use me:\n\n*Tell me what you're looking for:*\n    * Just type in what kind of service you need (like 'plumber,' 'electrician,' 'gardener,' 'handyman' etc.).\n    * I can understand things like 'my sink is leaking' or 'my lights are out.'\n\n*Tell me where you need it:*\n    * Give me a location! You can use:\n        * City and State (e.g., 'Brooklyn, New York')\n        * Zip code (e.g., '11204')\n        * Full address\n    * *Important:* Using a full address will provide the most accurate results.\n\n*Example:*\n    * If you need a plumber in 11204, you can try: 'Broken toilet in 11204'\n    * If you need an electrician in Brooklyn, New York, you can try: 'My lights are out in Brooklyn, New York'\n    * If you need a gardener at your house in New Jersey, you can try: 'I need a gardener at 123 Main St. Lakewood, NJ'\n\n_If you would like to sign up to be on our directory, reply 'sign up'._\n\n*Let's find the service you need! Just type your request below.* 😎")
                when "sign"
                    send_whatsapp_interactive("🚀 Ready to get more customers? 🚀", "Imagine your business popping up *exactly* when someone needs your service. We make it happen!\n\nPlus, you'll get your own dashboard to keep track of users who found you through our service. 👷🏼‍♂️", "", "Sign Up", "https://192dnsserver.com/sign_up", sender)
                else
                    begin
                        begin
                            ai_returned = find_correct_trade_ai(message)
                        rescue Exception => e
                            puts "Error with ai parse: #{e}"
                            send_whatsapp_message(sender, "We're sorry, something went wrong on our end. Please try again later.")
                            return
                        end
                        business_type, location = ai_returned.split("#")
                        if business_type.downcase == "unknown" || location.downcase == "unknown" || business_type.nil? || location.nil?
                            send_whatsapp_message(sender, "We're sorry, we couldn't understand your request. Please try again with _both_ the type of service needed and a location.")
                            return
                        end
                        puts business_type
                        puts location
                        # business_type_list = Business.business_types.keys
                        # business_type_index = business_type_list.index(business_type.downcase)
                        # puts business_type_index
                        business_type_id = BusinessType.find_or_create_by(name: business_type).id
                        relevant_businesses = Business.where(business_type: business_type_id)
                        puts relevant_businesses.inspect
                        relevant_businesses = relevant_businesses.select do |business|
                            if business.is_stationary
                                Geocoder::Calculations.distance_between(Geocoder.coordinates(location, params: { countrycodes: "us" }), [ business.latitude, business.longitude ]) <= 15
                            else
                                Geocoder::Calculations.distance_between(Geocoder.coordinates(location, params: { countrycodes: "us"}), [ business.latitude, business.longitude ]) <= business.mile_preference if business.mile_preference
                            end
                        end
                        count = relevant_businesses.size
                        puts count
                        if count == 0
                            send_whatsapp_message(sender, "We're sorry, we couldn't find any such businesses (#{business_type.humanize.capitalize}) near #{location}")
                            return
                        else
                            send_whatsapp_message(
                                sender,
                                "We found #{count} matching #{count == 1 ? "business" : "businesses" } near #{location}!" + "\n\n" + relevant_businesses.map {
                                    |b| "🏢 *#{ b.name }* \n\n 🔗 #{b.contact_url} \n\n 📞 #{ format_phone_number(b.phone_number) } \n ------------------------- " 
                                }.join("\n")
                                )
                        end
                        relevant_businesses.each do |business|
                            Event.create(business_id: business.id, event_type: 1)
                        end
                        render json: { message: "Message sent" }, status: :ok
                    rescue Exception => e
                        print e
                        send_whatsapp_message(sender, "We're sorry, something went wrong on our end. Please try again later.")
                        render json: { message: "Message sent" }, status: :ok
                    end
                end
            elsif statuses
                puts "Statuses: #{statuses["status"]}"
                render json: { message: "Status received" }, status: :ok
            else
                puts "weird phenomenon"
                render json: { message: "Unknown data received" }, status: :ok
            end
        else
            render json: { message: "Unsupported request method" }, status: :method_not_allowed
        end
    end

    def send_whatsapp_message(recipient, message)
        client = WhatsappSdk::Api::Client.new
        client.messages.send_text(sender_id: ENV.fetch("PHONE_NUMBER_ID"), recipient_number: recipient, message: message)
    end

    def reply_button_interactive(sender)
        client = WhatsappSdk::Api::Client.new
        interactive_header = WhatsappSdk::Resource::InteractiveHeader.new(type: "text", text: "I am the header!")
        interactive_body = WhatsappSdk::Resource::InteractiveBody.new(text: "I am the body!")
        interactive_footer = WhatsappSdk::Resource::InteractiveFooter.new(text: "I am the footer!")

        interactive_action = WhatsappSdk::Resource::InteractiveAction.new(type: "reply_button")
        interactive_reply_button_1 = WhatsappSdk::Resource::InteractiveActionReplyButton.new(
            title: "I am the 1",
            id: "button_1"
        )
        interactive_action.add_reply_button(interactive_reply_button_1)

        interactive_reply_button_2 = WhatsappSdk::Resource::InteractiveActionReplyButton.new(
            title: "I am the 2",
            id: "button_2"
        )
        interactive_action.add_reply_button(interactive_reply_button_2)

        interactive_reply_buttons = WhatsappSdk::Resource::Interactive.new(
            type: "reply_button",
            header: interactive_header,
            body: interactive_body,
            footer: interactive_footer,
            action: interactive_action
        )

        client.messages.send_interactive_reply_buttons(
            sender_id: ENV.fetch("PHONE_NUMBER_ID"), recipient_number: sender,
            interactive: interactive_reply_buttons
        )
    end

    def send_whatsapp_interactive(header_text, text, footer_text, button_text, button_url, sender)
        client = WhatsappSdk::Api::Client.new
        client.messages.send_interactive_list_messages(
            sender_id: ENV.fetch("PHONE_NUMBER_ID"), recipient_number: sender,
            interactive_json: {
                    "type": "cta_url",
                    "header": {
                    "type": "text",
                    "text": header_text
                    },
                    "body": {
                    "text": text
                    },
                    "footer": {
                    "text": footer_text
                    },
                    "action": {
                    "name": "cta_url",
                    "parameters": {
                        "display_text": button_text,
                        "url": button_url
                    }
                    }
                }
            )
    end

    def find_correct_trade_ai(message)
        client = OpenAI::Client.new
        response = client.chat(
          parameters: {
            model: "gpt-4o",
            messages: [
                { role: "user", content: 
                    "You are an expert in parsing user requests and extracting two key pieces of information: a business type and a location.

                    **Your task is to take the user's input and format it as follows:**

                    `[Business Type]#[Location]#your logic to the conclusion in 6 words or less`

                    **Here's how to determine each section:**

                    **1. Business Type:**

                    * You will receive a user request that implies a specific type of business.
                    * Use the following list to determine the appropriate business type. If the user request implies a business type not on this list, make your best educated guess from the list.
                        #{BusinessType.all.map(&:name)}

                    * For example:
                        * 'My sink is leaking' should translate to 'plumber'.
                        * 'Flower planting' should translate to 'gardener'.
                        * 'My roof is leaking' should translate to 'roofer'.
                        * The user can also directly specify the business type (e.g., 'plumber').

                    **2. Location:**

                    * The user's input will also contain a location.
                    * This location can be in various formats:
                        * City and State (e.g., 'Brooklyn, New York')
                        * Zip code (e.g., '11204')
                        * City name alone (e.g., 'Jackson')
                        * Full address (where you will return the whole thing correctly formatted)
                    * **Special Instruction for 'Jackson, NJ':**
                        * If the user specifies 'Jackson NJ' as the location, you MUST interpret this as 'Jackson Township, New Jersey'. Therefore, your output should be 'Jackson Township, New Jersey' in the location field.

                    **Example Input and Output:**

                    * **Input:** 'Broken toilet in 11204'
                    * **Output:** plumber#11204

                    * **Input:** 'I need a roofer in Brooklyn, New York'
                    * **Output:** roofer#Brooklyn, New York

                    * **Input:** 'Looking for a flower to be planted in Jackson NJ'
                    * **Output:** gardener#Jackson Township, New Jersey

                    * **Input:** 'I need a welder in 08527'
                    * **Output:** welder#Unknown (if no location is provided)

                    * **Input:** '08527'
                    * **Output:** Unknown#08527 (if no location is provided)

                    * **Input:** 'Where can I get my ac fixed in Boston, Massachusetts'
                    * **Output:** hvace#Boston, Massachusetts

                    * **Input:** 'Welder 11204'
                    * **Output:** welder#11204

                    **Your response CAN ONLY be the formatted output: `business_type#Location#reason`**

                    *** If one of them are not there, please return 'Unknown' for that field, but return the correct output for the other field that was included. ***

                    *** If you are unable to determine the business type or location, please return 'Unknown' for the corresponding field. ***

                    **** If there is anything other that a business type and location included in the message, please return 'Unknown' for both fields. ****

                    Here is the input#{message}"
                }
            ],
            temperature: 0.7
          }
        )
        puts response.dig("choices", 0, "message", "content")
        response.dig("choices", 0, "message", "content").downcase
    end

    def handle_click_and_redirect
        pn = params[:pn]
        id = params[:id] if params[:id]
        if id && id != ""
            business = Business.find(id)
        else
            business = Business.find_by(phone_number: pn)
        end
        puts business.inspect
        Event.create(business_id: business.id, event_type: 0)
        url = ""
        if business.communication_form == "whatsapp"
            url = "https://api.whatsapp.com/send?phone=#{pn}&text=Hey,+I+heard+about+you+from+Business+Directory"
        elsif business.communication_form == "sms"
            url = "sms:#{pn}&Body=Hey,%20I%20heard%20about%20you%20from%20Business%20Directory"
        elsif business.communication_form == "voice"
            url = "tel:#{pn}"
        elsif business.communication_form == "email"
            url = "mailto:#{pn}"
        end
        redirect_to url, allow_other_host: true
    end
end