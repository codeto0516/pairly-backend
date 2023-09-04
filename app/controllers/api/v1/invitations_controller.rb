class Api::V1::InvitationsController < ApplicationController

    # GET /invitations
    # 招待コードを発行
    def index


    end

    # POST /invitations
    # ユーザー同士のリレーションを作成
    # リンクをクリックした瞬間に、トークンの有効期限を設定する
    def create
        # トークンを元に招待情報を取得
        invitation = Invitation.where(invite_digest: params[:token])

        # 招待コードが存在しない場合
        if invitation.nil?
            render json: { message: "招待コードが存在しません。" }, status: :bad_request
            return
        end

        # パートナーがすでにいる場合
        if invitation.inviter && invitation.invitee
            render json: { message: "既にパートナーが存在します。" }, status: :bad_request
            return
        end

        # 初めてリンクをクリックした場合、トークンの有効期限を設定
        if invitation.expires_at.nil?
            invitation.update(expires_at:  Time.now + 1.day)

        # トークンの有効期限をチェック（リンクをクリックしてから時間が経っていた場合のため）
        elsif invitation.expires_at < Time.now
            render json: { message: "トークンの有効期限が切れています。" }, status: :bad_request
            return
        end

        # トークンも有効で、パートナーがいない場合は、招待を承認する
        uid = params[:uid] || nil
        if uid
            invitation.update(invitee: uid, status: "approved", expires_at: nil)
            render json: { message: "招待を承認しました。" }, status: :ok
        end

    end
    
    # GET /invitations/:id
    # ユーザー同士のリレーションを取得
    def show
        # 状態
        # ・一度目の招待
        # ・二度目以降の招待
        # ・招待中
        # ・招待承認済み

        uid = params[:id]
        latest_invitation = Invitation.where("inviter = :uid OR invitee = :uid", uid: uid)
                                                        .order(created_at: :desc).limit(1).first
        
        # もし招待履歴がない場合は、招待コードを作成して返す
        if latest_invitation.nil?
            # 招待コードを発行
            invite_digest = SecureRandom.urlsafe_base64

            # テーブルに保存
            invitation = Invitation.new(inviter: uid, invitee: nil, invite_digest: invite_digest, status: "pending")
            if invitation.save
                # URLを生成
                invitation_url = "http://localhost/signup?token=#{invite_digest}"

                render json: { message: "Invitation code has been issued.", data: {url: invitation_url} }, status: :ok
                return
            end
        end
    
        # もしすでにパートナーがいる場合は、招待コードを発行せずにパートナー情報を返す
        if latest_invitation.inviter && latest_invitation.invitee
            partner = latest_invitation.inviter == uid ? latest_invitation.invitee : latest_invitation.inviter
            render json: { message: "既にパートナーが存在します。", data: partner }, status: :bad_request
            return
        end


        if latest_invitation.status == "pending"
            render json: { 
                message: "Invitation is pending.", 
                data: {
                    invitation: latest_invitation,
                    url: "http://localhost/signup?token=#{latest_invitation.invite_digest}"
                }}, status: :ok
            return
        end

    end


    # DELETE /invitations/:id
    # ユーザー同士のリレーションを削除
    def destroy

    end


end