class MealFoodItemsController < ApplicationController
  include Authentication

  # POST /meals/:meal_id/meal_food_items
  def create
    @meal = Meal.find(params[:meal_id])
    @meal_food_item = @meal.meal_food_items.new(meal_food_item_params)

    if @meal_food_item.save
      render json: @meal_food_item.as_json(except: [ :created_at, :updated_at ]), status: :created
    else
      render json: @meal_food_item.errors, status: :unprocessable_content
    end
  end

  private
  def meal_food_item_params
    params.require(:meal_food_item).permit(:food_item_id, :portion_size)
  end
end
