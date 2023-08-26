# カテゴリー
yaml_file = Rails.root.join('db/seeds', 'categories.yml')
yaml_data = YAML.load_file(yaml_file)

yaml_data.each do |transaction_type_group|
  transaction_type = TransactionType.find_or_create_by(name: transaction_type_group["transaction_type"])
  
  transaction_type_group["categories"].each do |category_group|
    
    big_category = Category.find_or_create_by(name: category_group["parent"], parent_id: nil, transaction_type_id: transaction_type.id)
    category_group["children"].each do |child_category|
      small = Category.find_or_create_by(name: child_category, parent_id: big_category.id, transaction_type_id: transaction_type.id)
    end
  end
end
