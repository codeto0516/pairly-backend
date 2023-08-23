class Api::V1::UsersController < ApplicationController

    def index
        puts "==========================================="
        puts 


        puts "ここでindex"
        render status: 200, json: { message: @uid }
        puts "==========================================="

    end

    def show 
        user = User.find_by(uid: @uid)
    end

    def create 
        user = User.find_by(uid: @uid)
        if user.nil?
            # 既存のユーザデータがないなら新規作成
            @user = User.new(uid: @uid)
            if @user.save!
                render json: {message: "ユーザー登録成功！"}
            else
                render json: {message: "ユーザー登録失敗！"}
                
            end
        else 
            puts "既にユーザーが存在します"
        end
    end



end
