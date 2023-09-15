class Api::V1::TransactionsController < ApplicationController
  # before_action :transaction_params, only: [:create]
  before_action :set_transaction, only: [:show, :update, :destroy]
  # before_action :set_transaction_list, only: [:index]

  def get_transactions_for_specific_month
    # パラメータを取得
    year = params[:year].to_i
    month = params[:month].to_i


    # Time.zone.today.beginning_of_month
    # Time.zone.today.end_of_month

    # yearとmonthで指定された月の初日と最終日を取得
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    # 自分に関連する取引を取得
    transaction_amount_list = TransactionAmount.where(uid: @me[:local_id])

    # 指定月で絞り込み
    month_transactions = Transaction.where(id: transaction_amount_list.pluck(:transaction_id)).where(
      "paid_date between ? and ?", start_date, end_date
    )

    # 新しい日付順に並べ替え
    sorted_transactions = month_transactions.includes(
      :category,
      category: :transaction_type
    ).order(paid_date: :desc, id: :desc) # 新しい日付順、かつ、新しい取引順に並べ替え

    # レスポンス用のJSONを作成
    transaction_list = sorted_transactions.map do |transaction|
      {
        id: transaction.id,
        paid_date: transaction.paid_date,
        type: transaction.category.transaction_type.name,
        big_category_id: transaction.category.parent_id,
        small_category_id: transaction.category.id,
        content: transaction.content,
        created_by: transaction.created_by,
        amounts: transaction.transaction_amounts.map do |transaction_amount|
                   { user_id: transaction_amount.uid, amount: transaction_amount.amount }
                 end
      }.as_json(except: [:created_at, :updated_at])
    end

    # 総件数を取得
    total_count = month_transactions.count

    if transaction_list.empty?
      render json: {
        status: 'SUCCESS',
        message: 'Empty transaction list',
        data: {
          transactions: transaction_list,
          total_count:
        }
      }

    else
      render json: {
        status: 'SUCCESS',
        message: 'Loaded transaction list',
        data: {
          transactions: transaction_list,
          total_count:
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
      created_by: transaction_params[:created_by]
    )

    # 中間テーブルへ保存
    transaction_params[:amounts].each do |amount_params|
      transaction.transaction_amounts.build(
        related_transaction: transaction,
        uid: amount_params[:user_id],
        amount: amount_params[:amount]
      )
    end

    if transaction.save
      response = {
        id: transaction.id,
        paid_date: transaction.paid_date,
        type: transaction.category.transaction_type.name,
        big_category_id: transaction.category.parent_id,
        small_category_id: transaction.category.id,
        content: transaction.content,
        created_by: transaction.created_by,
        amounts: transaction.transaction_amounts.map do |transaction_amount|
                   { user_id: transaction_amount.uid, amount: transaction_amount.amount }
                 end
      }.as_json(except: [:created_at, :updated_at])
      render json: { status: 'SUCCESS', message: 'Transaction created', data: response }
    else
      Rails.logger.debug transaction.errors.inspect
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
      created_by: transaction_params[:created_by]
    )

    @transaction.transaction_amounts.destroy_all

    # 中間テーブルへ保存
    transaction_params[:amounts].each do |amount_params|
      @transaction.transaction_amounts.build(
        uid: amount_params[:user_id],
        amount: amount_params[:amount],
        related_transaction: @transaction
      )
    end

    if @transaction.save
      response = {
        id: @transaction.id,
        paid_date: @transaction.paid_date,
        type: @transaction.category.transaction_type.name,
        big_category_id: @transaction.category.parent_id,
        small_category_id: @transaction.category.id,
        content: @transaction.content,
        created_by: @transaction.created_by,
        amounts: @transaction.transaction_amounts.map do |transaction_amount|
                   { user_id: transaction_amount.uid, amount: transaction_amount.amount }
                 end
      }.as_json(except: [:created_at, :updated_at])


      render json: { status: :ok, message: 'Transaction updated', data: response }
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

  # ユーザーに紐づいた取引を取得
  def set_transaction_list
    @transactions = Transaction.all
  end
end
