class Api::V1::UsersController < Api::V1::BaseController
  require 'firebase/authentication'
  before_action :set_partner, only: [:me, :update]

  #############################################################################################################
  # GET /users/me
  #############################################################################################################
  def me
    me = fetch_user(@me[:local_id])
    render_response(:ok, "認証済みユーザーの情報取得に成功しました。", { user: json_format_me(me) })
  end

  #############################################################################################################
  # GET /users/:id
  #############################################################################################################
  def show
    user = fetch_user(params[:id])
    render_response(:ok, "指定されたユーザー情報の取得に成功しました。", { user: json_format_other(user) })
  end

  #############################################################################################################
  # PUT /users/:id
  #############################################################################################################
  def update
    # パラメータを取得
    display_name = params[:displayName] || nil
    image = params[:image] || nil

    # もし画像データがあれば、画像をアップロードしてURLを取得
    photo_url = Firebase::Storage.upload(params[:id], image) if image

    # プロフィールを更新
    user_profile = Firebase::Authentication.update(params[:id], display_name, photo_url)
    render_response(:ok, "ユーザー情報の更新に成功しました。", { user: json_format_me(user_profile) })
  end

  #############################################################################################################
  # PRIVATE METHOD
  #############################################################################################################
  private

  # ストロングパラメーター
  def user_params
    params.require(:user).permit(:local_id, :display_name, :email, :photo_url)
  end

  # Firebaseからユーザー情報を取得する
  def fetch_user(user_id)
    Firebase::Authentication.show(user_id)
  end

  # パートナーを取得する
  def set_partner
    # 最新の招待情報を取得
    latest_invitation = Invitation.where("inviter = :local_id OR invitee = :local_id", local_id: @me[:local_id])
      .order(created_at: :desc).limit(1).first

    @me[:partner] = nil

    if latest_invitation.present?
      # パートナーのIDを取得
      partner_id = latest_invitation.inviter == @me[:local_id] ? latest_invitation.invitee : latest_invitation.inviter

      # パートナーの情報を取得
      partner_data = fetch_user(partner_id)
      
      # パートナーの情報をセット
      if partner_data.present?
        @me[:partner] = json_format_other(partner_data) 
      end
    end
  end

  # 自分の情報のjsonを作成
  def json_format_me(user)
    {
      local_id: user.local_id,
      display_name: user.display_name,
      email: user.email,
      photo_url: user.photo_url,
      email_verified: user.email_verified,
      partner: @me[:partner],
      token: @token
    }
  end

  # 自分以外の情報のjsonを作成
  def json_format_other(user)
    {
      local_id: user.local_id,
      display_name: user.display_name,
      email: user.email,
      photo_url: user.photo_url
    }
  end
end
