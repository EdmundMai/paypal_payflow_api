require "paypal_payflow_api/version"
require 'net/http'
require 'uri'

module PaypalPayflowApi
  class Paypal
    attr_accessor :credit_card, :purchase, :billing_address

    def initialize(args={})
      # raise "PAYPAL_API hash constant must be defined with USER and PWD keys." if !defined?(PAYPAL_API)
      @credit_card = args[:credit_card]
      @purchase = args[:purchase]
      @billing_address = args[:billing_address]
    end

    def authorize_transaction(pnref)
      make_request(authorization_data(pnref))
    end

    def authorization_data(pnref)
      {
         "TRXTYPE" => "A",
         "TENDER" => "C",
         "USER" => PAYPAL_API["user"],
         "PWD" => PAYPAL_API["pwd"],
         "VENDOR" => PAYPAL_API["user"],
         "PARTNER" => "Paypal",
         "AMT" => purchase.total_price,
         "ORIGID" => pnref,
         "CUSTCODE" => purchase.id,
         "VERBOSITY" => "HIGH"
       }
    end


    def verify_billing_info
      make_request(verification_data)
    end

    def verification_data
      {
        "TRXTYPE" => "A",
        "TENDER" => "C",
        "USER" => PAYPAL_API["user"],
        "PWD" => PAYPAL_API["pwd"],
        "VENDOR" => PAYPAL_API["user"],
        "PARTNER" => "Paypal",
        "AMT" => 0.00,
        "ACCT" => credit_card["acct"],
        "EXPDATE" => credit_card["expmmyy"],
        "CVV2" => credit_card["cvv"],
        "FIRSTNAME" => purchase.billing_address.first_name,
        "LASTNAME" => purchase.billing_address.last_name,
        "STREET" => purchase.billing_address.full_address_line,
        "CITY" => purchase.billing_address.city,
        "STATE" => purchase.billing_address.state.code,
        "ZIP" => purchase.billing_address.postal_code,
        "VERBOSITY" => "HIGH"
      }
    end
    
    def params_format(data)
      params_in_text_format = ""
      data.each do |key, value|
        params_in_text_format << "#{key}=#{value}&"
      end
      params_in_text_format
    end

    private

      def make_request(data)
        uri = URI.parse(PAYPAL_API['payflow_url'])
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        request = Net::HTTP::Post.new(uri.path)
        request.body = params_format(data)
        response = https.request(request)
        resp_values = response.body.split("&").collect { |str| str.split("=") }
        return Hash[resp_values]
      end

  end

end
