class Api::V1::BaseController < ApplicationController
  require 'firebase/token_validator'
  before_action :authenticate, only: [:auth]

  # IDトークンを検証するだけのメソッド（ログイン時などに使う）
  def auth
    render_response(:ok, "認証に成功しました。", {})
  end

  #############################################################################
  # このクラス内とサブクラス内でのみアクセス可能
  #############################################################################
  protected

  # IDトークンの検証
  def authenticate
    # ヘッダーからトークンを取得
    token = request.headers["Authorization"]&.split&.last

    # もしトークンがなければ、エラーを返す。
    raise StandardError, "トークンをセットしてください。" if token.nil?

    # IDトークンの検証
    validator = Firebase::TokenValidator.new(token)
    payload = validator.validate!

    # もしpayloadがnilなら、トークンが不正なので、エラーを返す。
    raise StandardError, "認証に失敗しました。トークンの有効期限が切れているか、不正な値です。" if payload.nil?
    raise StandardError, "ユーザーIDが取得できませんでした。" if payload["user_id"].nil?

    @me = {
      local_id: payload["user_id"],
      token: token
    }

  # エラー処理
  rescue JWT::ExpiredSignature
    Rails.logger.error "トークンの有効期限が切れています。"
    return render_response(:unauthorized, "トークンの有効期限が切れています。", {})
  rescue JWT::DecodeError
    Rails.logger.error "トークンの検証に失敗しました。"
    return render_response(:unauthorized, "トークンの検証に失敗しました。", {})
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n") # エラーの詳細をログに出力したい場合はコメントアウトを外す
    render_response(:unauthorized, e.message, {})
  end

  # レスポンス形式の統一
  def render_response(status, message, data)
    # キャメルケースに変換
    converted_data = snake_to_camel(data)
    render status:, json: { message:, data: converted_data }
  end

  #############################################################################
  # このクラス内のみアクセス可能
  #############################################################################
  private

  # スネークケースからキャメルケースに変換
  def snake_to_camel(value)
    # もしvalueがハッシュだったら
    if value.is_a?(Hash)
      transformed_hash = {}
      value.each do |key, sub_value|
        camel_key = key.to_s.camelize(:lower).to_sym
        transformed_hash[camel_key] = snake_to_camel(sub_value)
      end
      transformed_hash

    # もしvalueが配列だったら
    elsif value.is_a?(Array)
      value.map { |item| snake_to_camel(item) }

    # それ以外はそのまま返す
    else
      value
    end
  end

end
