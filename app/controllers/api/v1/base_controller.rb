class Api::V1::BaseController < ApplicationController
    protected

    # レスポンス
    def render_response(status, message, data)
        # キャメルケースに変換
        converted_data = snake_to_camel(data)
        render status:, json: { message:, data: converted_data }
    end

    # スネークケースからキャメルケースに変換
    def snake_to_camel(value)
        # もしvalueがハッシュだったら
        if value.is_a?(Hash)
            transformed_hash = {}
            value.each do |key, sub_value|
                camel_key = key.to_s.camelize(:lower).to_sym
                transformed_hash[camel_key] = snake_to_camel(sub_value)
            end
            transformed_hash

        # もしvalueが配列だったら
        elsif value.is_a?(Array)
            value.map { |item| snake_to_camel(item) }

        # それ以外はそのまま返す
        else
            value
        end
    end

    # キャメルケースからスネークケースに変換
    def camel_to_snake(value)
        # もしvalueがハッシュだったら
        if value.is_a?(Hash)
            transformed_hash = {}
            value.each do |key, sub_value|
                snake_key = key.to_s.underscore.to_sym
                transformed_hash[snake_key] = keys_to_snake_case(sub_value)
            end
            transformed_hash

        # もしvalueが配列だったら
        elsif value.is_a?(Array)
            value.map { |item| keys_to_snake_case(item) }

        # それ以外はそのまま返す
        else
            value
        end
    end

    # def camel_to_snake(value)
    #     if value.is_a?(Hash)
    #         value.transform_keys { |key| key.to_s.underscore.to_sym }
    #         .transform_values { |val| camel_to_snake(val) }
    #     elsif value.is_a?(Array)
    #         value.map { |item| camel_to_snake(item) }
    #     else
    #         value
    #     end
    # end
end
