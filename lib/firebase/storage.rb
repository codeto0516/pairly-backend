require 'google/cloud/storage'

class Firebase::Storage

    # 初期化
    def self.initialize_bucket
        storage = Google::Cloud::Storage.new(
        project_id: ENV.fetch('FIREBASE_PROJECT_ID', nil),
        credentials: File.open("./serviceAccountKey.json")
        )
        bucket = storage.bucket ENV.fetch('FIREBASE_STORAGE_BUCKET', nil)
        bucket
    end

    # ファイルのアップロード（ファイルの上書き）
    def self.upload(local_id, image)
        @bucket ||= initialize_bucket
        extension = File.extname(image.original_filename)
        file = @bucket.create_file image.path, "images/#{local_id}.#{extension}", content_type: image.content_type
        file.signed_url expires: 24.hours
    end
end