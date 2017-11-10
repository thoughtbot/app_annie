module AppAnnie
  class Account

    attr_reader :raw,
                :id,
                :name,
                :status,
                :platform,
                :first_sales_date,
                :last_sales_date,
                :publisher_name

    def initialize(attributes)
      @raw = attributes
      @id = attributes['account_id']
      @name = attributes['account_name']
      @status = attributes['account_status']
      @platform = attributes['platform']
      @publisher_name = attributes['publisher_name']
      @first_sales_date = attributes['first_sales_date']
      @last_sales_date = attributes['last_sales_date']
    end

    def products(options = {})
      response = AppAnnie.connection.get do |req|
        req.headers['Authorization'] = "Bearer #{AppAnnie.api_key}"
        req.headers['Accept'] = 'application/json'
        req.url "#{API_ROOT}/#{id}/products", options
      end

      if response.status == 200
        JSON.parse(response.body)['products'].map { |hash| Product.new(self, hash) }
      else
        ErrorResponse.raise_for(response)
      end
    end

    def sales(options = {})
      response = AppAnnie.connection.get do |req|
        req.headers['Authorization'] = "Bearer #{AppAnnie.api_key}"
        req.headers['Accept'] = 'application/json'
        req.url "#{API_ROOT}/#{id}/sales", options
      end

      if response.status == 200
        JSON.parse(response.body)['sales_list']
      else
        ErrorResponse.raise_for(response)
      end
    end

  end
end
