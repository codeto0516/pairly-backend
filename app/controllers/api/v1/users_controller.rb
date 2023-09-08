class Api::V1::UsersController < ApplicationController
  require 'firebase_auth/user_profile'
  before_action :user_params, only: [:create, :update]
  # before_action :set_user, only: [ :update, :destroy]

  # GET /users/me
  def me
    render_success_response(:ok, "success to get user", @payload)
  end

  # GET /users/:id
  def show
    # パラメータからユーザーIDを取得
    uid = params[:id]

    # Invitationsテーブルからアクセスユーザーと取得したいユーザーのリレーションを取得
    invitation = Invitation.where("inviter_id = :user_id and invitee_id = :partner_id or inviter_id = :partner_id and invitee_id = :user_id", user_id: @payload["user_id"], partner_id: uid)

    # リレーションがない場合はアクセス権がないと判断
    if invitation.empty?
      render_failed_response(:not_found, "アクセス権のないユーザーIDです。")
      return
    end

    user_profile = FirebaseAuth::UserProfile.get_user_profile(uid)

    user = {
      displayName: user_profile.display_name,
      email: user_profile.email,
      photoURL: user_profile.photo_url
    }

    render_success_response(:ok, "success to get user", user)
  end

  private

  def render_success_response(status, message, user)
    render status:, json: {
      message:,
      data: {
        user: user.as_json(except: [:uid, :created_at, :updated_at])
      }
    }
  end

  def render_failed_response(status, message)
    render status:, json: {
      message:
    }
  end
end
