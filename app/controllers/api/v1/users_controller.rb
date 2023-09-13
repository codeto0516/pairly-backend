class Api::V1::UsersController < ApplicationController
  require 'firebase/authentication'
  before_action :set_partner

  # GET /users/me
  def me
    me = Firebase::Authentication.show(@me[:local_id])
    @me[:display_name] = me.display_name
    @me[:email] = me.email
    @me[:photo_url] = me.photo_url
    @me[:email_verified] = me.email_verified
    render_success_response(:ok, "success to get user", @me)
  end

  # GET /users/:id
  def show
    user = Firebase::Authentication.show(params[:id])
    @user[:display_name] = user.display_name
    @user[:email] = user.email
    @user[:photo_url] = user.photo_url
    @user[:email_verified] = user.email_verified
    render_success_response(:ok, "success to get user", @user)
  end

  # PUT /users/:id
  def update
    display_name = params[:displayName] || nil
    image = params[:image] || nil
    photo_url = Firebase::Storage.upload(params[:id], image) if image
    user_profile = Firebase::Authentication.update(params[:id], display_name, photo_url)
    @me[:display_name] = user_profile.display_name
    @me[:photo_url] = user_profile.photo_url
    render_success_response(:ok, "success to update user", @me)
  end

  private

  # パートナーを取得する
  def set_partner
    latest_invitation = Invitation.where("inviter = :local_id OR invitee = :local_id", local_id: @me[:local_id]).order(created_at: :desc).limit(1).first
    @me[:partner] = nil
    if latest_invitation.present?
      partner_local_id = latest_invitation.inviter == @me[:local_id] ? latest_invitation.invitee : latest_invitation.inviter
      partner_data = Firebase::Authentication.show(partner_local_id)
      if partner_data.present?
        @me[:partner] = {
          local_id: partner_data.local_id,
          display_name: partner_data.display_name,
          email: partner_data.email,
          photo_url: partner_data.photo_url
        }
      end
    end
  end

  # キーをスネークケースからキャメルケースに変換するヘルパーメソッド
  def keys_to_camel_case(value)
    if value.is_a?(Hash)
      transformed_hash = {}
      value.each do |key, sub_value|
        camel_key = key.to_s.camelize(:lower).to_sym
        transformed_hash[camel_key] = keys_to_camel_case(sub_value)
      end
      transformed_hash
    elsif value.is_a?(Array)
      value.map { |item| keys_to_camel_case(item) }
    else
      value
    end
  end

  # 成功レスポンス
  def render_success_response(status, message, user)
    camel_user = keys_to_camel_case(user)
    render status:status , json: {
      message:,
      data: {
        user: camel_user
      }
    }
  end

  # 失敗レスポンス
  def render_failed_response(status, message)
    render status:, json: {
      message:
    }
  end
end
