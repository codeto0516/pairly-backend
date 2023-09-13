class ApplicationController < ActionController::API
  require 'firebase/token_validator'

  before_action :set_token
  before_action :token_valid?

  def auth
    success_response(:ok, "トークンの検証に成功しました。")
  end

  private

  # リクエストヘッダーからトークンを取得する。
  def set_token
    @token = request.headers["Authorization"]&.split&.last
    return faild_response(:unauthorized, "トークンをセットしてください。") if @token.nil?
  end

  # 取得したトークンが正しいかどうかを検証する
  def token_valid?
    begin
      validator = Firebase::TokenValidator.new(@token)
      payload = validator.validate!

    rescue JWT::ExpiredSignature
      Rails.logger.error "トークンの有効期限が切れています。"
      return faild_response(:unauthorized, "認証に失敗しました。トークンの有効期限が切れています。")
    rescue StandardError => e
      return faild_response(:unauthorized, "認証に失敗しました。エラーメッセージ => #{e.message}")
      Rails.logger.debug "=" * 60 # rubocop:disable Lint/UnreachableCode
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      Rails.logger.debug "=" * 60
    end

    # もしpayloadがnilなら、トークンが不正なので、エラーを返す。
    return faild_response(:unauthorized, "認証に失敗しました。トークンの有効期限が切れているか、不正な値です。") if payload.nil?

    @me = {
      local_id: payload["user_id"],
      token: @token
    }


  end

  def success_response(status, message)
    render status:, json: { message: }
  end

  def faild_response(status, message)
    render status:, json: { error: { message: } }
  end
end
