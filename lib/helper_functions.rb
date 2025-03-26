module HelperFunctions
    def strip_phone_number(pn)
        pn_numbers_only = pn.gsub!(/[^0-9]/, '')
        return pn if pn.length == 11
        return "1#{pn}" if pn.length == 10
    end

    def format_phone_number(pn)
        pn_numbers_only = pn.gsub!(/[^0-9]/, '')
        return "(#{pn[1..3]})-#{pn[4..6]}-#{pn[7..10]}"
    end
end