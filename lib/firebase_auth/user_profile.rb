require 'json'
require 'net/http'

class FirebaseAuth::UserProfile
  FIREBASE_API_KEY = ENV.fetch('FIREBASE_API_KEY', nil)
  FIREBASE_AUTH_DOMAIN = ENV.fetch('FIREBASE_AUTH_DOMAIN', nil)

  def self.get_user_profile(uid)
    service = Google::Apis::IdentitytoolkitV3::IdentityToolkitService.new
    service.key = FIREBASE_API_KEY

    service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open("./serviceAccountKey.json"),
      scope: [
        # 認可が必要なスコープを列挙する。今回はidentitytoolkitのみ
        # ここにFirebaseの各種サービスを指定することでUserManagement以外も利用可能
        'https://www.googleapis.com/auth/identitytoolkit',
      ].join(' ')
    )

    request = Google::Apis::IdentitytoolkitV3::GetAccountInfoRequest.new(local_id: [uid])
    response = service.get_account_info(request)

    if response.kind_of?(Google::Apis::IdentitytoolkitV3::GetAccountInfoResponse)
      user_profiles = response.users
      user_profiles.first
    else
      nil
    end
  end
end


