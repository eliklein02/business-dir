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
    else
      @business.business_type = BusinessType.find_by(name: unhumanize(business_params[:business_type])).id
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
          "**Task:** Business Category Validation, Classification, and Creation

**Instructions:**

You are a business category expert. You will receive:

* A list of **Existing Categories:** #{BusinessType.all.map(&:name)}
* A **User Description:** #{input} of a business activity.

Your goal is to:

1.  **Validate:** First, confirm whether the 'User Description' fits into any of the 'Existing Categories'.
2.  **Classify or Create:** Then, accurately classify or create a business category for the provided user description.

**Process:**

1.  **Comparison and Validation:**
    * Carefully compare the 'User Description' to each 'Existing Category'.
    * Determine if the 'User Description' *closely* matches any existing category, even with slight variations in wording.
2.  **Match (General):**
    * If the 'User Description' broadly matches an 'Existing Category', return the *most general* matching category in snake\_case.
    * Example: 'I bake cakes' should match 'baker', not 'cake_baker'.
3.  **Match (Niche):**
    * If the 'User Description' describes a highly specialized niche within a broader category, return a *specific* category name in snake_case that captures the niche.
    * Example: 'I create artisan sourdough bread' should match 'artisan_bread_maker', not just 'baker'.
    * Example: 'Hand-tooled leather wallets' should match 'handcrafted_leather_goods', not 'leatherwork'.
4.  **Create (New):**
    * If no existing category adequately fits the 'User Description', create a *new*, concise, and descriptive category name in snake_case.
    * The new category should be as precise as possible, reflecting the unique aspects of the business.
    * Consider materials, techniques, audience, specialization, or niche.
    * Example: 'Custom miniature wargaming terrain' should become 'miniature_wargaming_terrain_creator' and not 'crafts'.
    * Example: 'Specialized repair of vintage mechanical watches' should become 'vintage_mechanical_watch_repair' and not 'watch_repair'.
5.  **Specificity:**
    * Avoid overly broad or vague categories unless the user description is itself broad.
    * Prioritize accuracy and meaningful distinctions.
    * If the user description is broad, the returning category should also be broad.
    * If the user description is niche, the returning category must be niche.

**Output:**

Return *only* the category name in snake_case (either the existing matching category or the newly created category). Do not include any additional text or explanations."
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
