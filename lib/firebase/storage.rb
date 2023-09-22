require 'google/cloud/storage'

class Firebase::Storage

    # 初期化
    def self.initialize_bucket
        # serviceAccountKey.jsonをデコードして環境変数にセットする　base64 -w 0 serviceAccountKey.json > Base64ServiceAccountKey.txt

        # 環境変数を取得する
        encoded_service_account_key = ENV.fetch('FIREBASE_SERVICE_ACCOUNT_KEY', nil)

        # デコードする
        decoded_service_account_key = Base64.decode64(encoded_service_account_key)

        # JSONをパースする
        service_account_key = JSON.parse(decoded_service_account_key)

        # バケットを初期化する
        storage = Google::Cloud::Storage.new(
            project_id: ENV.fetch('FIREBASE_PROJECT_ID', nil),
            credentials: service_account_key
        )

        # バケットを取得する
        storage.bucket ENV.fetch('FIREBASE_STORAGE_BUCKET', nil)
    end

    # ファイルのアップロード（ファイルの上書き）
    def self.upload(local_id, image)
        # バケットを初期化する
        @bucket ||= initialize_bucket

        # ファイルの拡張子を取得する
        extension = File.extname(image.original_filename)

        # ファイルをアップロードする
        file = @bucket.create_file image.path, "images/#{local_id}.#{extension}", content_type: image.content_type

        # ファイルのURLを取得する（有効期限は24時間）
        file.signed_url
    end
end
