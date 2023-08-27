class Api::V1::TransactionsController < ApplicationController
    before_action :transaction_params, only: [:create]

    before_action :set_transaction, only: [:show, :update, :destroy]

    def index 

        page = params[:page] || 1
        per_page = params[:per_page] || 10
        
        transactions = Transaction.includes(
            :category, 
            :category => :transaction_type, 
            :transaction_users => :user
        ).paginate(page: page, per_page: per_page)

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

        if transaction_list.empty?
            render json: { status: 'SUCCESS', message: 'Empty transaction list', data: transaction_list }

        else 
            render json: { status: 'SUCCESS', message: 'Loaded transaction list', data: transaction_list }
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
        if @transaction.update(transaction_params.except(:amounts))
            @transaction.transaction_users.destroy_all
            @transaction.transaction_users.build(transaction_params[:amounts])
            @transaction.save
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
    end



end
