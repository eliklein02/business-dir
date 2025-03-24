# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
business_types = [ "electrician", "plumber", "gardener", "painter", "graphic_artist", "handyman", "carpenter", "roofer", "mason", "welder", "hvac", "pest_control", "landscaper", "cleaning_service" ]
communication_forms = [ "whatsapp", "sms", "voice" ]
addresses = ["1763 48th street", "65 citadel drive"]
businesses = []

addresses.each do |address|
    2.times do
        businesses << {
            name: Faker::Company.name,
            rating: rand(1.0..5.0).round(1),
            phone_number: Faker::PhoneNumber.phone_number,
            business_type: business_types.sample,
            address: address,
            city: address == "1763 48th street" ? "Brooklyn" : "Jackson Township",
            state: address == "1763 48th street" ? "NY" : "NJ",
            communication_form: communication_forms.sample,
            mile_preference: rand(1..20),
        }
    end
end

businesses.each do |business|
    Business.find_or_create_by!(business)
end