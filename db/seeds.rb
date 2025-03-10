# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
trades = ["Plumber", "Electrician", "Carpenter", "Painter", "Mechanic", "Chef", "Teacher", "Doctor", "Lawyer", "Engineer"]
names = ["John Doe", "Jane Smith", "Alice Johnson", "Robert Brown", "Michael Davis", "Emily Wilson", "David Martinez", "Sarah Lee", "Daniel White", "Laura Harris"]
zip_codes = ["10001", "90210", "33101", "60601", "73301", "94101", "02101", "30301", "48201", "70112"]

businesses = 10.times.map do
    {
        business_type: trades.sample,
        name: names.sample,
        zip_code: zip_codes.sample,
        rating: rand(1.0..5.0).round(1)
    }
end

businesses.each do |b|
    bus = Business.find_or_create_by(name: b[:name], business_type: b[:business_type], zip_code: b[:zip_code], rating: b[:rating])
end
