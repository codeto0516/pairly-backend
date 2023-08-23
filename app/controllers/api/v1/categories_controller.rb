class Api::V1::CategoriesController < ApplicationController

    def index 
        puts "kjdlsfaskldfjsd;lfdlk;fj"
        render json: [{
            big_category_id: 1,
            big_category: "未分類",
            small_categories: [
                {
                    small_category_id: 1,
                    small_category: "未分類",
                },
            ],
        },]
    end
end
