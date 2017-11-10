require 'spec_helper'

describe AppAnnie::Account do
  describe 'building an account from a hash' do
    it "parses the hash" do
      raw_hash = {
        "account_id"=>110000,
        "platform"=>"ITC",
        "last_sales_date"=>"2014-01-05",
        "account_status"=>"OK",
        "first_sales_date"=>"2013-12-07",
        "publisher_name"=>"AppCo",
        "account_name"=>"AppCo iTunes"
      }

      expect(AppAnnie::Account.new(raw_hash)).to have_attributes(
        raw: raw_hash,
        id: 110000,
        name: 'AppCo iTunes',
        status: 'OK',
        platform: 'ITC',
        first_sales_date: '2013-12-07',
        last_sales_date: '2014-01-05',
        publisher_name: 'AppCo'
      )
    end
  end

  describe 'retrieving a list of products' do
    let(:account) { AppAnnie::Account.new('account_id' => 123) }
    let(:path) { '/v1.2/accounts/123/products' }
    before { allow(AppAnnie).to receive(:connection).and_return(stub_connection) }

    describe 'successfully' do
      let(:mock_resp_file) { File.expand_path("../../api_fixtures/products.json", __FILE__) }
      let(:stub_connection) do
        Faraday.new do |builder|
          builder.adapter :test do |stub|
            stub.get(path) {[200, {}, File.read(mock_resp_file)]}
          end
        end
      end

      it 'returns an array of AppAnnie::Product objects' do
        result = account.products
        expect(result.size).to eq(1)
        expect(result.first.class).to be(AppAnnie::Product)
      end

      it 'sets properties appropriately from the response' do
        product = account.products.first
        expect(product.account).to be(account)
        expect(product.status).to eq(true)
        expect(product.name).to eq('App Annie')
        expect(product.id).to eq(1)
        expect(product.last_sales_date).to eq('2017-11-04')
        expect(product.first_sales_date).to eq('2016-04-17')
        expect(product.icon).to eq('https://scontent-frx5-1.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/13643693_140395686402695_1534494044_n.jpg')
        expect(product.market).to eq('ios')
        expect(product.devices).to eq(['Universal'])
        expect(product.device_codes).to eq(["iphone", "ipad"])
      end
    end

    describe 'when an authorization error is encountered' do
      let(:stub_connection) do
        Faraday.new do |builder|
          builder.adapter(:test) { |stub| stub.get(path) {[ 401, {}, '' ]} }
        end
      end
      it 'raises an exception' do
        expect { account.products}.to raise_error(AppAnnie::Unauthorized)
      end
    end

    describe 'when a rate limit error is encountered' do
      let(:stub_connection) do
        Faraday.new do |builder|
          builder.adapter(:test) { |stub| stub.get(path) {[ 429, {}, '' ]} }
        end
      end
      it 'raises an exception' do
        expect { account.products }.to raise_error(AppAnnie::RateLimitExceeded)
      end
    end

    describe 'when a server error is encountered' do
      let(:stub_connection) do
        Faraday.new do |builder|
          builder.adapter(:test) { |stub| stub.get(path) {[ 500, {}, '' ]} }
        end
      end
      it 'raises an exception' do
        expect { account.products }.to raise_error(AppAnnie::ServerError)
      end
    end

    describe 'when a maintenance error is encountered' do
      let(:stub_connection) do
        Faraday.new do |builder|
          builder.adapter(:test) { |stub| stub.get(path) {[ 503, {}, '' ]} }
        end
      end
      it 'raises an exception' do
        expect { account.products }.to raise_error(AppAnnie::ServerUnavailable)
      end
    end
  end
end

