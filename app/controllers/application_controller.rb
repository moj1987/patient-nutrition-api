class ApplicationController < ActionController::API
  def reset_db
    return head :forbidden unless Rails.env.development?
    [ MealFoodItem, Meal, FoodItem, Patient ].each do |model|
      model.connection.execute("TRUNCATE TABLE #{model.table_name} RESTART IDENTITY CASCADE")
    end
    render json: { message: "Database reset successfully" }
  end
end
