class FoodItemsController < ApplicationController
  def index
    @food_items = FoodItem.all
    render json: @food_items
  end

  def show
    @food_item = FoodItem.find(params[:id])
    render json: @food_item
  end

  def create
    @food_item = FoodItem.new(food_items_params)
    if @food_item.save
      render json: @food_item, status: :created
    else
      render json: @food_item.errors, status: :unprocessable_entity
    end
  end

  private
  def food_items_params
    params.require(:food_item).permit(:name, :calories, :protein, :carbs, :fat, dietary_restrictions: [])
  end
end
