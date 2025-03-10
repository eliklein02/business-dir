class PagesController < ApplicationController
    def index
    end

    def privacy_policy
    end

    def show_businesses
        businesses = Business.all
        respond_to do |format|
            format.html { render :index, locals: { title: "Home", businesses: businesses } }
        end
    end

    def show
        business = Business.find_by(id: params[:id])
        if business
            respond_to do |format|
                format.html { render :show, locals: { business: business } }
            end
        else
            render json: { message: "not found" } and return if business.nil?
        end
    end
end