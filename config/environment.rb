# Load the Rails application.
require_relative "application"

def format_phone_number(pn)
    pn_numbers_only = pn.gsub!(/[^0-9]/, '')
    return "(#{pn[1..3]})-#{pn[4..6]}-#{pn[7..10]}"
end

# Initialize the Rails application.
Rails.application.initialize!
