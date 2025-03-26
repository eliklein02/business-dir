class BusinessesController < ApplicationController
  include HelperFunctions

  def new
    @business = Business.new
  end

  def create
    @business = Business.new(business_params)
    if @business.address.split("#")[1] == "admin"
      @business.admin = true
    end
    @business.phone_number = strip_phone_number(@business.phone_number)
    if @business.save
      session[:business_id] = @business.id
      redirect_to @business, notice: "Business added"
    else
      puts @business.errors.full_messages
      render :new
    end
  end

  def show
    @business = Business.find(params[:id])
    authorize_business
  end

  def index
    protect_route
    @businesses = Business.all
  end

  def edit
    @business = Business.find(params[:id])
  end

  def update
    @business = Business.find(params[:id])
    @business.phone_number = strip_phone_number(@business.phone_number)
    if @business.update(business_params)
      redirect_to @business
    else
      redirect_to :edit
    end
  end

  private

  def business_params
    params.require(:business).permit(:name, :email, :password, :password_confirmation, :address, :city, :state, :mile_preference, :business_type, :phone_number, :communication_form, :rating)
  end
end
