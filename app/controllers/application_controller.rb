class ApplicationController < ActionController::API

  require 'firebase_auth/token_validator'
  before_action :authenticate
  class AuthenticationError < StandardError; end
  rescue_from AuthenticationError, with: :handle_authentication_error

  def authenticate

    # リクエストヘッダーからトークンを取得
    token = request.headers["Authorization"]&.split&.last
    
    # もしトークンがなければ例外処理
    raise AuthenticationError, "not token" if token.nil?
    
    validator = FirebaseAuth::TokenValidator.new(token)
    @payload = validator.validate!

    if @payload
      puts "認証成功！"
    end
  end

  private
    def handle_authentication_error(error)
      render json: { error: { messages: [error.message] } }, status: :unauthorized
    end
    
end
