require 'spec_helper'

describe AppAnnie::Product do
  describe '#initialize' do
    let(:account) { AppAnnie::Account.new({}) }
    let(:raw_hash) do
      {
        "status" => true,
        "product_name" => "Test App",
        "product_id" => 456,
        "last_sales_date" => "2017-11-04",
        "first_sales_date" => "2016-04-17",
        "icon" => "https://scontent-frx5-1.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/13643693_140395686402695_1534494044_n.jpg",
        "device_codes" => ["iphone", "ipad"],
        "devices" => ["Universal"],
        "market" => "ios"
      }
    end

    it "builds an AppAnnie product from the account and hash data" do
      expect(AppAnnie::Product.new(account, raw_hash)).to have_attributes(
        account: account,
        raw: raw_hash,
        id: 456,
        name: 'Test App',
        status: true,
        icon: 'https://scontent-frx5-1.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/13643693_140395686402695_1534494044_n.jpg',
        first_sales_date: '2016-04-17',
        last_sales_date: '2017-11-04',
        device_codes: ["iphone", "ipad"],
        devices: ["Universal"],
        market: "ios"
      )
    end
  end

  describe 'retrieving a list of sales' do
    let(:account) { AppAnnie::Account.new('account_id' => 123) }
    let(:product) { AppAnnie::Product.new(account, {'product_id' => 456})}
    let(:path) { "/v1.2/accounts/#{account.id}/products/#{product.id}/sales" }
    before { allow(AppAnnie).to receive(:connection).and_return(stub_connection) }

    describe 'successfully' do
      let(:mock_resp_file) { File.expand_path("../../api_fixtures/product_sales.json", __FILE__) }
      let(:stub_connection) do
        Faraday.new do |builder|
          builder.adapter :test do |stub|
            stub.get(path) {[200, {}, File.read(mock_resp_file) ]}
          end
        end
      end

      it 'returns an array of sales data' do
        result = product.sales

        expect(result.size).to eq(1)
      end
    end

    describe 'when an authorization error is encountered' do
      let(:stub_connection) do
        Faraday.new do |builder|
          builder.adapter(:test) { |stub| stub.get(path) {[ 401, {}, '' ]} }
        end
      end
      it 'raises an exception' do
        expect { product.sales }.to raise_error(AppAnnie::Unauthorized)
      end
    end

    describe 'when a rate limit error is encountered' do
      let(:stub_connection) do
        Faraday.new do |builder|
          builder.adapter(:test) { |stub| stub.get(path) {[ 429, {}, '' ]} }
        end
      end
      it 'raises an exception' do
        expect { product.sales }.to raise_error(AppAnnie::RateLimitExceeded)
      end
    end

    describe 'when a server error is encountered' do
      let(:stub_connection) do
        Faraday.new do |builder|
          builder.adapter(:test) { |stub| stub.get(path) {[ 500, {}, '' ]} }
        end
      end
      it 'raises an exception' do
        expect { product.sales }.to raise_error(AppAnnie::ServerError)
      end
    end

    describe 'when a maintenance error is encountered' do
      let(:stub_connection) do
        Faraday.new do |builder|
          builder.adapter(:test) { |stub| stub.get(path) {[ 503, {}, '' ]} }
        end
      end
      it 'raises an exception' do
        expect { product.sales }.to raise_error(AppAnnie::ServerUnavailable)
      end
    end
  end
end

