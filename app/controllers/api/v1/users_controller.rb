class Api::V1::UsersController < ApplicationController

    require 'firebase_auth/user_profile'
    before_action :user_params, only: [:create, :update]
    # before_action :set_user, only: [ :update, :destroy]

    # GET /users
    def index
        # @user = User.find_by(uid: @payload["user_id"])

        # if @user.nil?
        #     # 既存のユーザデータがないなら新規作成
        #     @user = User.new(uid: @payload["user_id"], email: @payload["email"], name: @payload["name"], image: @payload["picture"])
            
        #     if @user.save!
        #         render_success_response(:created, "success to create user", @user)
        #     else
        #         render_failed_response(:unprocessable_entity, "failed to create user")
        #     end
        # end

        # render_success_response(:ok, "success to get user", @payload)
   
    end

    # GET /users/:id
    def show
        # if @user.nil?
        #     render_failed_response(:not_found, "user not found")
        # else
        #     render_success_response(:ok, "success to get user", @user, nil)
        # end

        uid = params[:id]
        user_profile = FirebaseAuth::UserProfile.get_user_profile(uid)

        user = {
            displayName: user_profile.display_name,
            email: user_profile.email,
            photoURL: user_profile.photo_url,
        }
        
        render_success_response(:ok, "success to get user", user)

    end

    # PUT /users/:id
    def update
        name = user_params["name"] || @user.name
        image = user_params["image"] || @user.image

        if @user.update(name: name, image: image)
            render_success_response(:ok, "success to update user", @user)
        else
            render_failed_response(:unprocessable_entity, "failed to update user")
        end
    end

    # DELETE /users/:id
    def destroy
        # @user.destroy
        # render_success_response(:ok, "success to delete user", nil)
    end

    private

    def user_params
        params.require(:user).permit(:name, :email, :image)
    end

    def set_user
        @user = User.find(params[:id])
    end

    def partner
        # 自分が含まれる過去全てのリレーションリストを取得
        invitations = Invitation.where("inviter_id = :user_id or invitee_id = :user_id", user_id: @user.id)

        if invitations.empty?
            return nil
        end

        # 最新のリレーションを取得
        latest_invitation = invitations.order(created_at: :desc).first

        # パートナーのIDを取得
        latest_partner_id = latest_invitation.inviter_id == @user.id ? latest_invitation.invitee_id : latest_invitation.inviter_id

        # パートナーの情報を取得
        partner = User.find(latest_partner_id)

        partner
    end

    def render_success_response(status, message, user)
        render status: status, json: {
            message: message,
            data: {
                user: user.as_json(except: [:uid, :created_at, :updated_at]),
            }
        }
    end

    def render_failed_response(status, message)
        render status: status, json: {
            message: message,
        }
    end

end
