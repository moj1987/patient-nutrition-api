class MealFoodItemsController < ApplicationController
  # POST /meals/:meal_id/meal_food_items
  def create
    @meal = Meal.find(params[:meal_id])
    @meal_food_item = @meal.meal_food_items.create!(meal_food_items_params)

    render json: @meal_food_item, status: :created

  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.message }, status: :unprocessable_entity
  end

  private
  def meal_food_items_params
    params.require(:meal_food_item).permit(:food_item_id, :portion_size)
  end
end
