class FoodItemsController < ApplicationController
  include Authentication

  def index
    @food_items = FoodItem.all
    render json: @food_items
  end

  def show
    @food_item = FoodItem.find(params[:id])
    render json: @food_item
  end

  def create
    @food_item = FoodItem.new(food_item_params)
    if @food_item.save
      render json: @food_item, status: :created
    else
      render json: @food_item.errors, status: :unprocessable_entity
    end
  end

  private

  def set_food_item
    @food_item = FoodItem.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Food item not found" }, status: :not_found
  end

  def food_item_params
    params.require(:food_item).permit(:name, :calories, :protein, :carbs, :fat, :fiber, :sugar, :sodium, dietary_restrictions: [])
  end
end
