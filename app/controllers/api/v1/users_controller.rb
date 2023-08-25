class Api::V1::UsersController < ApplicationController

    # ユーザー情報取得
    def index
        puts @payload
        user = User.find_by(uid: @payload["user_id"])
        if user.nil?
            # 既存のユーザデータがないなら新規作成
            user = User.new(uid: @payload["user_id"], email: @payload["email"], name: @payload["name"], image: @payload["picture"])
            if user.save!
                render json: {user: user, message: "ユーザー登録が成功しました。"}, status: :created
            else
                render json: {user: user, message: "ユーザー登録が失敗しました。"}, status: :unprocessable_entity
            end
        else
            render json: {user: user, message: "既存のユーザー情報を返します。"}, status: :ok
        end
    end

end
    # def create 
    #     @user = User.find_or_create_by(uid: @payload.uid, name: @payload.name, picture: @payload.picture)
    #     if @user.persisted?
    #         render json: @user, status: :created
    #     else
    #         render json: {errors: "ユーザー登録失敗！"}, status: :unprocessable_entity
    #     end
    # end