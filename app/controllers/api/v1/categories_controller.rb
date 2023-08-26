class Api::V1::CategoriesController < ApplicationController

    def index
        transaction_type = TransactionType.find(1)

        big_cagegories = transaction_type.categories.where(parent_id: nil)
        

        category_list = big_cagegories.map do |big_cagegory|
            {
                big_category_id: big_cagegory.id,
                big_category_name: big_cagegory.name,
                small_categories: transaction_type.categories.where(parent_id: big_cagegory.id).map do |small_category|
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


# {
#     big_cagegory_id: 1,
#     big_cagegory_name: "食費",
#     small_categories: [
#         {
#             small_category_id: 1,
#             small_category_name: "食料品"
#         }
#     ]
# }