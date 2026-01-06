class MealsController < ApplicationController
  before_action :set_meal, only: %i[ show update destroy ]

  # GET /meals
  def index
    @patient = Patient.find(params[:patient_id])
    @meals = @patient.meals

    render json: @meals
  end

  # GET /meals/1
  def show
    @meal = Meal.find(params[:id])
    render json: {
      meal_type: @meal.meal_type,
      status: @meal.status,
      nutrition_summary: @meal.nutrition_summary
    }
  end

  # POST /meals
  def create
    @patient = Patient.find(params[:patient_id])
    @meal = @patient.meals.new(meal_params)

    if @meal.save
      render json: @meal, status: :created
    else
      render json: @meal.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /meals/1
  def update
    if @meal.update(meal_params)
      render json: @meal
    else
      render json: @meal.errors, status: :unprocessable_content
    end
  end

  # DELETE /meals/1
  def destroy
    @meal.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_meal
      @meal = Meal.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def meal_params
      params.require(:meal).permit(:meal_type, :status)
    end
end
