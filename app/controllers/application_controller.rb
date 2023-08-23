class ApplicationController < ActionController::API

  require 'firebase_auth/token_validator'
  before_action :authenticate
  class AuthenticationError < StandardError; end
  rescue_from AuthenticationError, with: :handle_authentication_error

  def authenticate
    puts "======================================================"

    # リクエストヘッダーからトークンを取得
    token = request.headers["Authorization"]&.split&.last
    
    # もしトークンがなければ例外処理
    raise AuthenticationError, "not token" if token.nil?
    
    validator = FirebaseAuth::TokenValidator.new(token)
    payload = validator.validate!
    # raise AuthenticationError unless current_user(payload["user_id"])
    if payload
      puts "認証成功！"
      @uid = payload["user_id"]
    end
    puts "======================================================"

  end

  # def current_user(user_id = nil)
  #   @current_user ||= User.find_by(uid: user_id)
  # end

  private


  def handle_authentication_error(error)
    render json: { error: { messages: [error.message] } }, status: :unauthorized
  end
    
end
