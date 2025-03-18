class BusinessesController < ApplicationController
  def new
    @business = Business.new
  end

  def create
    @business = Business.new(business_params)
    if @business.save
      redirect_to @business, notice: "Business added"
    else
      render :new
    end
  end

  def show
    @business = Business.find(params[:id])
  end

  def index
    @businesses = Business.all
  end

  private

  def business_params
    params.require(:business).permit(:name, :address, :business_type, :phone_number, :communication_form, :rating)
  end
end
