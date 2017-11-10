module AppAnnie
  class Product

    attr_reader :raw,
                :account,
                :id,
                :account_id,
                :status,
                :name,
                :first_sales_date,
                :last_sales_date,
                :icon,
                :device_codes,
                :devices,
                :market

    def initialize(account, attributes)
      @raw = attributes
      @account = account
      @id = attributes['product_id']
      @name = attributes['product_name']
      @status = attributes['status']
      @icon = attributes['icon']
      @first_sales_date = attributes['first_sales_date']
      @last_sales_date = attributes['last_sales_date']
      @device_codes = attributes['device_codes']
      @devices = attributes['devices']
      @market = attributes['market']
    end

    def sales(options = {})
      response = AppAnnie.connection.get do |req|
        req.headers['Authorization'] = "Bearer #{AppAnnie.api_key}"
        req.headers['Accept'] = 'application/json'
        req.url "#{API_ROOT}/#{@account.id}/products/#{@id}/sales", options
      end

      if response.status == 200
        JSON.parse(response.body)['sales_list']
      else
        ErrorResponse.raise_for(response)
      end
    end

  end
end
