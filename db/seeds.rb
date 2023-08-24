
# カテゴリー
yaml_file = Rails.root.join('db/seeds', 'categories.yml')
yaml_data = YAML.load_file(yaml_file)

yaml_data.each do |data|
  # 取引種別（支出、収入...）
  transaction_type = TransactionType.find_or_create_by(name: data["transaction_type_name"])

  data["categories"].each do |categories|

    big_category = BigCategory.find_or_create_by(name: categories["big_category_name"], transaction_type_id: transaction_type.id)
   
    categories["small_categories"].each do |small_category_name|
      SmallCategory.find_or_create_by(name: small_category_name, big_category_id: big_category.id)
    end

  end
end
