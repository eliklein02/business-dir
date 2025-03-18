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
                return if messages["type"] == "reaction"
                business_type_list = [ "electrician", "plumber", "gardener", "painter", "graphic artist" ]
                sender = messages["from"]
                message = messages["text"]["body"]
                first_word = message.split(" ").first.downcase
                case first_word
                when "hi", "hello", "hey"
                    send_whatsapp_message(sender, "👋 *Welcome to Business Directory!*\n\nUse this bot to find local businesses. For example, 'broken toilet brooklyn ny', or 'electrician in lakewood nj \n\n _You can always reply 'help' for instructions._ ")
                    render json: { message: "Message sent" }, status: :ok
                when "t"
                    send_whatsapp_interactive("Business Directory", "Tap the button below to visit our website.", "Find local businesses easily!", "Visit Website", "https://businessdirectory.com", sender)
                when "r"
                    reply_button_interactive(sender)
                else
                    begin
                        ai_returned = find_correct_trade_ai(message)
                        business_type, location = ai_returned.split("#")
                        business_type_index = business_type_list.index(business_type.downcase)
                        location_as_array = location.downcase.split(" ")
                        # if location_as_array.include?("jackson")
                        #     location_as_array[location_as_array.index("jackson")] = "jackson township"
                        # end
                        location = location_as_array.join(" ")
                        # location_coordinates = Geocoder.coordinates(location)
                        relevant_businesses = Business.near(location, 10, params: { countrycodes: "us" })
                        relevant_businesses = relevant_businesses.where(business_type: business_type_index)
                        count = relevant_businesses.size
                        if count == 0
                            send_whatsapp_message(sender, "We're sorry, we couldn't find any businesses near #{location}")
                        else
                            send_whatsapp_message(
                                sender,
                                "We found #{count} matching #{count == 1 ? "business" : "businesses" } near #{location}!" + "\n\n" + relevant_businesses.map {
                                    |b| "👤 #{ b.name } \n\n 📞 #{shorten_url(b.communication_form, b.phone_number)} \n\n ⭐️ #{ b.rating } \n ------------------------- " 
                                }.join("\n")
                                )
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

                    `[Business Type]#[Location]`

                    **Here's how to determine each section:**

                    **1. Business Type:**

                    * You will receive a user request that implies a specific type of business.
                    * Use the following list to determine the appropriate business type. If the user request implies a business type not on this list, make your best educated guess from the list.
                        * Plumber
                        * Electrician
                        * Gardener
                        * Graphic Artist

                    * For example:
                        * 'My sink is leaking' should translate to 'Plumber'.
                        * 'I need a haircut' should translate to 'Hair Salon'.

                    **2. Location:**

                    * The user's input will also contain a location.
                    * This location can be in various formats:
                        * City and State (e.g., 'Brooklyn, New York')
                        * Zip code (e.g., '11204')
                        * City name alone (e.g., 'Jackson')
                        * Full address (where you will return the whole thing correctly formatted)
                    * **Special Instruction for 'Jackson':**
                        * If the user specifies 'Jackson' as the location, you MUST interpret this as 'Jackson Township, New Jersey'. Therefore, your output should be 'Jackson Township, New Jersey' in the location field.

                    **Example Input and Output:**

                    * **Input:** 'Broken toilet in 11204'
                    * **Output:** Plumber#11204

                    * **Input:** 'I need a restaurant in Brooklyn, New York'
                    * **Output:** Restaurant#Brooklyn, New York

                    * **Input:** 'Looking for a mechanic in Jackson'
                    * **Output:** Mechanic#Jackson Township, New Jersey

                    * **Input:** 'My teeth hurt, I need a dentist'
                    * **Output:** Dentist#Unknown (if no location is provided)

                    * **Input:** 'Where can I buy milk in Boston, Massachusetts?'
                    * **Output:** Grocery Store#Boston, Massachusetts

                    **Your response should ONLY be the formatted output: `[Business Type]#[Location]`**

                    Here is the input#{message}"
                }
            ],
            temperature: 0.7
          }
        )
        puts response.dig("choices", 0, "message", "content")
        response.dig("choices", 0, "message", "content").downcase
    end

    def shorten_url(c_f, pn)
        puts "starting for #{c_f} and #{pn}"
        if c_f == "whatsapp"
            whatsapp_url = "https://api.whatsapp.com/send?phone=#{pn}&text=Hey,+I+heard+about+you+from+Business+Directory"
            new_url = HTTParty.get("https://tinyurl.com/api-create.php?url=#{whatsapp_url}").body
        elsif c_f == "sms"
            sms_url = "sms:#{pn}&Body=Hey,%20I%20heard%20about%20you%20from%20Business%20Directory"
            new_url = HTTParty.get("https://tinyurl.com/api-create.php?url=#{sms_url}").body
        end
        new_url
    end
end
