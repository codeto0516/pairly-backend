class Api::V1::CategoriesController < Api::V1::BaseController

  def index
    # 全ての取引タイプを取得
    category_all = TransactionType.all.map do |transaction_type|
      {
        type_name: transaction_type.name,
        categories: generate_category_list(transaction_type)
      }
    end

    render_response(:ok, "カテゴリーリストの取得に成功しました。", { types: category_all.as_json(except: [:created_at, :updated_at]) })
  end

  # GET /categories/:type_name
  def show
    transaction_type = TransactionType.find_by(name: params[:type_name])

    # もしtransaction_typeがなければ例外処理
    if transaction_type.nil?
      render_failed_response(:not_found, "指定された取引タイプが存在しません。")
      return
    end

    category_list = generate_category_list(transaction_type)

    if category_list.empty?
      render_response(:not_found, "指定された取引タイプに属するカテゴリーが存在しません。", {})
    else
      render_response(:ok, "カテゴリーリストの取得に成功しました。", { categories: category_list })
    end
  end

  private

  # 指定された取引タイプに属する、大カテゴリーのリストを生成
  def generate_category_list(transaction_type)
    transaction_type.categories.where(parent_id: nil).map do |big_category|
      {
        big_category_id: big_category.id,
        big_category_name: big_category.name,
        small_categories: generate_small_categories(big_category)
      }
    end
  end

  # 指定された大カテゴリーに属する、小カテゴリーのリストを生成
  def generate_small_categories(big_category)
    big_category.children.map do |small_category|
      {
        small_category_id: small_category.id,
        small_category_name: small_category.name
      }
    end
  end
end
