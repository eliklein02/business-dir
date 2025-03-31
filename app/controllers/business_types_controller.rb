class BusinessTypesController < ApplicationController
    def create
        @business_type = BusinessType.create(business_type_params)
        redirect_to admin_path
    end

    def destroy
        @business_type = BusinessType.find(params[:id])
        @business_type&.destroy
        redirect_to admin_path
    end

    private

    def business_type_params
        params.require(:business_type).permit(:name)
    end
end
