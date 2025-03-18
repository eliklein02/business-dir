# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
businesses = [
    { name: "John's Electrical", address: "860 E. 27th st, Brooklyn, NY", business_type: 0, rating: 4.5 },
    { name: "Green Thumb Gardens", address: "456 Ridge Ave, Lakewood, NJ", business_type: 2, rating: 4.0 },
    { name: "Plumb Perfect", address: "1350 50th st, Brooklyn, NY", business_type: 1, rating: 3.8 },
    { name: "Electric Experts", address: "4 xavier Dr, Jackson Townshsp, NJ", business_type: 0, rating: 4.7 },
    { name: "Garden Gurus", address: "5803 20th ave, Brooklyn, NY", business_type: 2, rating: 4.2 },
    { name: "Plumbing Pros", address: "14 Tuscanny terrace, Lakewood, NJ", business_type: 1, rating: 4.1 }
    # { name: "Bright Sparks", address: "404 Brooklyn Ave, Brooklyn, NY", business_type: "Electrician", rating: 4.9 },
    # { name: "Lush Landscapes", address: "505 Lakewood Blvd, Lakewood, NJ", business_type: "Gardener", rating: 3.9 },
]

businesses.each do |business|
    Business.find_or_create_by!(business)
end