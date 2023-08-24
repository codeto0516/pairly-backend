class Api::V1::CategoriesController < ApplicationController

    def index
        transaction_type = TransactionType.find(1)

        category_list = transaction_type.big_categories.map do |big_category|
            {
                big_category_id: big_category.id,
                big_category_name: big_category.name,
                small_categories: big_category.small_categories.map do |small_category|
                    {
                        small_category_id: small_category.id,
                        small_category_name: small_category.name
                    }
                end
            }
        end

        render json: category_list
    end
end
