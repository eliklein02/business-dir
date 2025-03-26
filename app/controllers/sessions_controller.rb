class SessionsController < ApplicationController
    def new
        @business = Business.new()
    end

    def create
        puts params
        pn = strip_phone_number(params[:phone_number])
        if params[:id]
            @business = Business.find_by(phone_number: pn, id: params[:id])
        else
            @business = Business.find_by(phone_number: pn)
        end
        if @business.authenticate(params[:password])
            session[:business_id] = @business.id
            redirect_to business_path(@business)
        else
            puts "nah man"
        end
    end

    def destroy
        session[:business_id] = nil
        redirect_to root_path
    end
end