require 'json'
require 'net/http'

class Firebase::Authentication
    FIREBASE_API_KEY = ENV.fetch('FIREBASE_API_KEY', nil)
    FIREBASE_AUTH_DOMAIN = ENV.fetch('FIREBASE_AUTH_DOMAIN', nil)

  def self.initialize_service
    service = Google::Apis::IdentitytoolkitV3::IdentityToolkitService.new
    service.key = FIREBASE_API_KEY

    # serviceAccountKey.jsonをデコードして環境変数にセットする　base64 -w 0 serviceAccountKey.json > Base64ServiceAccountKey.txt

    # 環境変数を取得する
    encoded_service_account_key = ENV.fetch('FIREBASE_SERVICE_ACCOUNT_KEY', nil)

    # デコードする
    decoded_service_account_key = Base64.decode64(encoded_service_account_key)

    service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(decoded_service_account_key),
        scope: [
            'https://www.googleapis.com/auth/identitytoolkit'
        ].join(' ')
    )
    service
  end

  def self.show(local_id)
    @service ||= initialize_service
    request = Google::Apis::IdentitytoolkitV3::GetAccountInfoRequest.new(local_id: [local_id])
    response = @service.get_account_info(request)

    if response.is_a?(Google::Apis::IdentitytoolkitV3::GetAccountInfoResponse)
      user_profiles = response.users
      user_profiles.first
    end
  end

  def self.update(local_id, display_name, photo_url)
    @service ||= initialize_service
    request = Google::Apis::IdentitytoolkitV3::SetAccountInfoRequest.new(local_id:, display_name:, photo_url:)
    response = @service.set_account_info(request)
    response if response.is_a?(Google::Apis::IdentitytoolkitV3::SetAccountInfoResponse)
  end
end
