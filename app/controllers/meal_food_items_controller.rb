class MealFoodItemsController < ApplicationController
  # POST /meals/:meal_id/meal_food_items
  def create
    @meal = Meal.find(params[:meal_id])
    @meal_food_item = @meal.meal_food_items.create!(meal_food_items_params)

    if @meal_food_item.persisted?
      render json: @meal_food_item.as_json(except: [ :created_at, :updated_at ]), status: :created
    else
      render json: { errors: @meal.errors.messages }, status: :unprocessable_entity
    end
  end

  private
  def meal_food_items_params
    params.require(:meal_food_item).permit(:food_item_id, :portion_size)
  end
end
