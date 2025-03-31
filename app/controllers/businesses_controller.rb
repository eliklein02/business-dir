class BusinessesController < ApplicationController
  include HelperFunctions

  def new
    @business = Business.new
  end

  def create
    @business = Business.new(business_params)
    if params[:business][:other] != ""
      category = extract_category(params[:business][:other])
      b = BusinessType.find_or_create_by(name: category)
      @business.business_type = b.id
    end
    if @business.address.split("#")[1] == "admin"
      @business.admin = true
    end
    if @business.city.strip == "Jackson" || @business.city.strip == "jackson"
      @business.city = "Jackson Township"
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
    @business.assign_attributes(business_params)
    puts business_params
    if business_params[:other] != ""
      category = extract_category(business_params[:other])
      b = BusinessType.find_or_create_by(name: category)
      @business.business_type = b.id
    end
    if @business.address.split("#")[1] == "admin"
      @business.admin = true
    end
    puts @business.inspect
    if @business.city.strip == "Jackson" || @business.city.strip == "jackson"
      @business.city = "Jackson Township"
    end
    @business.phone_number = strip_phone_number(@business.phone_number)
    if @business.save
      redirect_to @business
    else
      redirect_to :edit
    end
  end

  def destroy
    @business = Business.find(params[:id])
    if @business && current_business && current_business.id == @business.id
      b = Business.find(@business.id)
      if b
        b.destroy
        redirect_to root_path
      else
        redirect_to root_path
      end
    else
      redirect_to root_path
    end
  end

  private

  def extract_category(input)
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
      model: "gpt-4o",
      messages: [
        { role: "user", content:
          "**Prompt:**

          You are a business category validator and creator. You will be provided with a list of existing business categories and a user-provided description of a business activity, which the user claims does *not* fit into any of the existing categories. Your task is to verify this claim.

          **Input:**

          * **Existing Categories:** #{BusinessType.all.map(&:name)}
          * **User Description:** #{input}

          **Instructions:**

          1. Carefully compare the 'User Description' to each 'Existing Category'.
          2. If, despite the user's claim, the 'User Description' *does* closely match an 'Existing Category' (even with slight variations in wording), return *only* the matching 'Existing Category' name. This indicates the user made an error.
          3. If, as the user claims, the 'User Description' genuinely does *not* match any existing category, create a new, concise, and descriptive category name that accurately reflects the 'User Description'. 
          4. Ensure the new category is specific and not overly broad. For example:
            - A 'custom suit maker' should not be categorized as a general 'tailor'.
            - An 'artisan bread maker' should not be categorized as a general 'baker'.
          5. Think conceptually: the goal is to create or match a category that is as precise as possible for any situation. Avoid generic terms and focus on the unique aspects of the business activity. For instance:
            - Consider the materials, techniques, or audience involved in the business.
            - Acknowledge distinctions in specialization, such as 'handcrafted leather goods' versus 'general leatherwork'.
            - Reflect on the purpose or niche of the business, such as 'wedding photography' versus 'general photography'.
          6. Avoid overly generic or vague categories. The goal is to create or match a category that is as precise and meaningful as possible.

          **Output:**

          Return *only* the category name (either the existing matching category or the newly created category). DO NOT include any additional text or explanations."
        }
      ],
      temperature: 0.7
      }
    )
    puts response.dig("choices", 0, "message", "content")
    response.dig("choices", 0, "message", "content").downcase
  end

  def business_params
    params.require(:business).permit(:name, :email, :other, :is_stationary, :password, :password_confirmation, :address, :city, :state, :mile_preference, :business_type, :phone_number, :communication_form, :rating)
  end
end
