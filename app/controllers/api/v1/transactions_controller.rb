class Api::V1::TransactionsController < ApplicationController
    before_action :transaction_params, only: [:create]
    before_action :set_transaction, only: [:show, :update, :destroy]

    def index

        # パラメータを取得
        start_date = params[:start_date] || Date.today.beginning_of_month
        end_date = params[:end_date] || Date.today.end_of_month
        page = params["page"] || 1
        per_page = params["per-page"] || 10


        # 指定月で絞り込み
        month_transactions = Transaction.where("paid_date between ? and ?", start_date, end_date)
        
        # 新しい日付順に並べ替え
        sorted_transactions = month_transactions.includes(
            :category, 
            :category => :transaction_type, 
            :transaction_users => :user
        ).order(paid_date: :desc, id: :desc)  # 新しい日付順、かつ、新しい取引順に並べ替え

        # ページネーション
        transactions = sorted_transactions.paginate(page: page, per_page: per_page)

        # レスポンス用のJSONを作成
        transaction_list = transactions.map do |transaction|
            {
                id: transaction.id,
                paid_date: transaction.paid_date,
                type: transaction.category.transaction_type.name,
                big_category_id: transaction.category.parent_id,
                small_category_id: transaction.category.id,
                content: transaction.content,
                created_by: transaction.created_by_id,
                amounts: transaction.transaction_users.map do |transaction_user|
                    { user_id: transaction_user.user_id, amount: transaction_user.amount}
                end
            }.as_json(except: [:created_at, :updated_at])
        end

        # 総件数を取得
        total_count = Transaction.count

        if transaction_list.empty?
            render json: { 
                status: 'SUCCESS', 
                message: 'Empty transaction list', 
                data: {
                    transactions: transaction_list,
                    total_count: total_count,
                }
            }

        else 
            render json: { 
                status: 'SUCCESS', 
                message: 'Loaded transaction list',
                data: {
                    transactions: transaction_list,
                    total_count: total_count,
                } 
            }
        end

    end

    # POST /transactions
    def create

        # トランザクションの作成
        transaction = Transaction.new(
            paid_date: transaction_params[:paid_date], 
            category_id: transaction_params[:small_category_id],
            content: transaction_params[:content], 
            created_by_id: transaction_params[:created_by]
        )

        # 中間テーブルへ保存
        transaction_params[:amounts].each do |amount_params|
            transaction.transaction_users.build(
                user_id: amount_params[:user_id], 
                amount: amount_params[:amount],
                related_transaction: transaction
            )
        end

        if transaction.save
            render json: { status: 'SUCCESS', message: 'Transaction created', data: transaction }
        else
            puts transaction.errors.inspect
            render json: { status: 'ERROR', message: 'Failed to create transaction', data: transaction.errors }
        end
    end

    # PUT /transactions/:id
    def update

        # トランザクションの作成
        @transaction.update(
            paid_date: transaction_params[:paid_date], 
            category_id: transaction_params[:small_category_id],
            content: transaction_params[:content], 
            created_by_id: transaction_params[:created_by]
        )

        @transaction.transaction_users.destroy_all

        # 中間テーブルへ保存
        transaction_params[:amounts].each do |amount_params|
            @transaction.transaction_users.build(
                user_id: amount_params[:user_id], 
                amount: amount_params[:amount],
                related_transaction: @transaction
            )
        end

        if @transaction.save
            render json: { status: 'SUCCESS', message: 'Transaction updated', data: @transaction }
        else
            render json: { status: 'ERROR', message: 'Failed to update transaction', data: @transaction.errors }
        end
    end

    # DELETE /transactions/:id
    def destroy
        if @transaction.destroy
            render json: { status: 'SUCCESS', message: 'Deleted the transaction', data: @transaction }
        else
            render json: { status: 'ERROR', message: 'Not deleted', data: @transaction.errors }
        end
    end

    private

    def transaction_params
        params.permit(:id, :paid_date, :content, :type, :created_by, :big_category_id, :small_category_id, amounts: [:user_id, :amount])
    end

    def set_transaction
        @transaction = Transaction.find(params[:id])
        puts @transaction.inspect

    end



end
