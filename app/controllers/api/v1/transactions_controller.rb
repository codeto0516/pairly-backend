class Api::V1::TransactionsController < ApplicationController
  before_action :set_transaction, only: [:update, :destroy]
  before_action :set_params, only: [:create, :update]

  #############################################################################################################
  # GET /transactions
  #############################################################################################################
  def index
    # パラメータを取得
    year = params[:year].to_i | Time.zone.today.year
    month = params[:month].to_i | Time.zone.today.month
    # sort = params[:sort] | 'desc'

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
    transactions = sorted_transactions.map do |transaction|
      response_format(transaction)
    end

    # 総件数を取得
    total_count = transactions.count

    # レスポンス
    render_response(:ok, '指定月の取引一覧の取得に成功しました。', { transactions:, total_count: })
  end

  #############################################################################################################
  # POST /transactions
  #############################################################################################################
  # POST /transactions
  def create
    ActiveRecord::Base.transaction do
      # トランザクションの作成
      transaction = Transaction.new(@params.except(:amounts))

      # 中間テーブルへ保存
      save_transaction_amounts(transaction, @params[:amounts])

      if transaction.save
        render_response(:ok, '取引の作成に成功しました。', { transaction: response_format(transaction) })
      else
        render_response(:internal_server_error, '取引の作成に失敗しました。', nil)
      end

    rescue ActiveRecord::RecordInvalid => e
      render_response(:internal_server_error, "取引の作成に失敗しました。詳細 => #{e.message}", nil)
    end
  end

  #############################################################################################################
  # PUT /transactions/:id
  #############################################################################################################
  def update
    ActiveRecord::Base.transaction do
      if @transaction.update(@params.except(:amounts))

        # 指定されたトランザクションに紐づく中間テーブルを全て削除
        @transaction.transaction_amounts.clear

        # 中間テーブルを再度作成し、保存する
        save_transaction_amounts(@transaction, @params[:amounts])

        if @transaction.save
          render_response(:ok, '取引の更新に成功しました。', { transaction: response_format(@transaction) })
        else
          render_response(:internal_server_error, '取引の更新に失敗しました。', nil)
        end

      else
        render_response(:internal_server_error, '取引の更新に失敗しました。', nil)
      end

    rescue ActiveRecord::RecordInvalid => e
      render_response(:internal_server_error, "取引の更新に失敗しました。詳細 => #{e.message}", nil)

    end
  end

  #############################################################################################################
  # DELETE /transactions/:id
  #############################################################################################################
  def destroy
    if @transaction.destroy
      render_response(:ok, '取引の削除に成功しました。', nil)
    else
      render_response(:internal_server_error, '取引の削除に失敗しました。', nil)
    end
  end

  #############################################################################################################
  # PRIVATE METHOD
  #############################################################################################################
  private

  # ストロングパラメータ
  def transaction_params
    params.permit(:id, :paid_date, :content, :type, :created_by, :small_category_id, amounts: [:user_id, :amount])
  end

  # idで指定された取引を取得しセット
  def set_transaction
    @transaction = Transaction.find(params[:id])
    # 取引が見つからない場合
    if @transaction.nil?
      return render_response(:not_found, '指定された取引が見つかりません。', nil)
    end

    # 指定された取引の中間テーブルに自分のIDが含まれていない場合
    unless @transaction.transaction_amounts.pluck(:uid).include?(@me[:local_id])
      return render_response(:forbidden, '権限がありません。', nil)
    end
  end

  # パラメータをセット
  def set_params
    @params = {
      paid_date: transaction_params[:paid_date],
      category_id: transaction_params[:small_category_id],
      content: transaction_params[:content],
      created_by: transaction_params[:created_by],
      amounts: transaction_params[:amounts]
    }
  end

  # 中間テーブルに保存
  def save_transaction_amounts(transaction, amounts)
    amounts.each do |amount|
      transaction.transaction_amounts.build(
        uid: amount[:user_id],
        amount: amount[:amount],
        related_transaction: transaction
      )
    end
  end

  # レスポンス用のJSONを作成
  def response_format(transaction)
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

  # レスポンス
  def render_response(status, message, data)
    render status:, json: { message:, data: }
  end

end
