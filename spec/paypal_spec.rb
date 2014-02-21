require 'spec_helper'

describe PaypalPayflowApi::Paypal do
  
  describe "#initialize" do
    
    before do
      PAYPAL_API = { user: "123123", pwd: "abc123"}
    end
    
    it "sets the purchase attribute" do
      purchase = { amt: '22.22', id: '123' }
      paypal = PaypalPayflowApi::Paypal.new(purchase: purchase)
      expect(paypal.purchase).to eq(purchase)
    end
  
    it "sets the credit_card attribute" do
      credit_card = { acct: '5105105105105100', expmmyy: '1215', cvv: '123' }
      paypal = PaypalPayflowApi::Paypal.new(credit_card: credit_card)
      expect(paypal.credit_card).to eq(credit_card)
    end
  
    it "sets the billing_address attribute" do
      billing_address = { first_name: 'Ronald', last_name: 'McDonald', street: '123 Fake Street',
                          city: 'New York', state: 'NY', zip_code: '10013' }
      paypal = PaypalPayflowApi::Paypal.new(billing_address: billing_address)
      expect(paypal.billing_address).to eq(billing_address)
    end
  end 

   
  describe "#params_format(data)" do
    let(:credit_card) { {"acct"=>"5105105105105100", "expmmyy"=>"1215", "cvv" => "123"} }
    let(:billing_address) { FactoryGirl.create(:address) }
    let(:purchase) { FactoryGirl.create(:purchase, bill_addr_id: billing_address.id, total_price: 999.00) }
    let(:paypal) { PaypalPayflowApi::Paypal.new(purchase: purchase, credit_card: credit_card) }
    
    it "returns verification_data in params format" do
      desired_text = "TRXTYPE=A&TENDER=C&USER=leeandlow257&PWD=stardate?652&VENDOR=leeandlow257&PARTNER=PaypalPayflowApi::Paypal&AMT=0.0&ACCT=5105105105105100&EXPDATE=1215&CVV2=123&FIRSTNAME=Nettheory&LASTNAME=address&STREET=Nettheory addressSuite 3000&CITY=Nettheory City address&STATE=NY&ZIP=5458482&CUSTCODE=#{purchase.id}&VERBOSITY=HIGH&"
      paypal.params_format(paypal.verification_data).should == desired_text
    end
  end
  
  describe "#authorization_data(pnref)" do
    let(:purchase) { FactoryGirl.create(:purchase, total_price: 999.00) }
    let(:paypal) { PaypalPayflowApi::Paypal.new(purchase: purchase) }
    
    it "returns a hash with a TENDER key with value C" do
      expect(paypal.authorization_data("123")["TENDER"]).to eq("C")
    end

    it "returns a hash with a USER key" do
      expect(paypal.authorization_data("123")["USER"]).to eq(PAYPAL_API["user"])
    end

    it "returns a hash with a PWD key" do
      expect(paypal.authorization_data("123")["PWD"]).to eq(PAYPAL_API["pwd"])
    end

    it "returns a hash with a VENDOR key" do
      expect(paypal.authorization_data("123")["VENDOR"]).to eq(PAYPAL_API["user"])
    end

    it "returns a hash with a PARTNER key" do
      expect(paypal.authorization_data("123")["PARTNER"]).to eq("PaypalPayflowApi::Paypal")
    end

    it "returns a hash with a CUSTCODE key with value of purchase.id" do
      expect(paypal.authorization_data("123")["CUSTCODE"]).to eq(purchase.id)
    end

    it "returns a hash with a VERBOSITY key" do
      expect(paypal.authorization_data("123")["VERBOSITY"]).to eq("HIGH")
    end
    
    it "returns a hash with a ORIGID key equal to the pnref argument" do
      expect(paypal.authorization_data("123")["ORIGID"]).to eq("123")
    end
    
  end
  
  describe "#verification_data" do
    let(:credit_card) { {"acct"=>"5105105105105100", "expmmyy"=>"1215", "cvv" => "123"} }
    let(:billing_address) { FactoryGirl.create(:address) }
    let(:purchase) { FactoryGirl.create(:purchase, bill_addr_id: billing_address.id, total_price: 999.00) }
    let(:paypal) { PaypalPayflowApi::Paypal.new(purchase: purchase, credit_card: credit_card) }
    
    it "returns a hash with a TRXTYPE key with value A" do
      expect(paypal.verification_data["TRXTYPE"]).to eq("A")
    end
    
    it "returns a hash with a AMT key with value 0" do
      expect(paypal.verification_data["AMT"]).to be == 0.00
    end
    
    it "returns a hash with a ACCT key" do
      expect(paypal.verification_data["ACCT"]).to eq(credit_card["acct"])
    end

    it "returns a hash with a EXPDATE key" do
      expect(paypal.verification_data["EXPDATE"]).to eq(credit_card["expmmyy"])
    end

    it "returns a hash with a CVV2 key" do
      expect(paypal.verification_data["CVV2"]).to eq(credit_card["cvv"])
    end

    it "returns a hash with a FIRSTNAME key" do
      expect(paypal.verification_data["FIRSTNAME"]).to eq(purchase.billing_address.first_name)
    end

    it "returns a hash with a LASTNAME key" do
      expect(paypal.verification_data["LASTNAME"]).to eq(purchase.billing_address.last_name)
    end

    it "returns a hash with a STREET key" do
      expect(paypal.verification_data["STREET"]).to eq(purchase.billing_address.full_address_line)
    end

    it "returns a hash with a CITY key" do
      expect(paypal.verification_data["CITY"]).to eq(purchase.billing_address.city)
    end

    it "returns a hash with a STATE key" do
      expect(paypal.verification_data["STATE"]).to eq(purchase.billing_address.state.code)
    end

    it "returns a hash with a ZIP key" do
      expect(paypal.verification_data["ZIP"]).to eq(purchase.billing_address.postal_code)
    end

    it "returns a hash with a TENDER key with value C" do
      expect(paypal.verification_data["TENDER"]).to eq("C")
    end

    it "returns a hash with a USER key" do
      expect(paypal.verification_data["USER"]).to eq(PAYPAL_API["user"])
    end

    it "returns a hash with a PWD key" do
      expect(paypal.verification_data["PWD"]).to eq(PAYPAL_API["pwd"])
    end

    it "returns a hash with a VENDOR key" do
      expect(paypal.verification_data["VENDOR"]).to eq(PAYPAL_API["user"])
    end

    it "returns a hash with a PARTNER key" do
      expect(paypal.verification_data["PARTNER"]).to eq("PaypalPayflowApi::Paypal")
    end

    it "returns a hash with a CUSTCODE key with value of purchase.id" do
      expect(paypal.verification_data["CUSTCODE"]).to eq(purchase.id)
    end

    it "returns a hash with a VERBOSITY key" do
      expect(paypal.verification_data["VERBOSITY"]).to eq("HIGH")
    end
    
  end
  
  describe "authorize_transaction(pnref)" do
    let(:purchase) { purchase = FactoryGirl.create(:purchase, total_price: 999.00)}
    let(:response) {
      paypal = PaypalPayflowApi::Paypal.new(purchase: purchase) 
      pnref = "A10A6A9C08E1"       
      paypal.authorize_transaction(pnref)
    }
    
    context "the transaction was approved" do
      before do
        successful_response = "RESULT=0&PNREF=A10A6A9C2391&RESPMSG=Approved&AUTHCODE=013PNI&AVSADDR=Y&AVSZIP=Y&HOSTCODE=A&PROCAVS=Y&VISACARDLEVEL=12&TRANSTIME=2014-01-31 12:16:07&FIRSTNAME=net&LASTNAME=theory&AMT=15.64&ACCT=1111&EXPDATE=0115&CARDTYPE=0&IAVS=N"
        stub_request(:post, "https://pilot-payflowpro.paypal.com/").
          with(:body => "TRXTYPE=A&TENDER=C&USER=leeandlow257&PWD=stardate?652&VENDOR=leeandlow257&PARTNER=PaypalPayflowApi::Paypal&AMT=999.0&ORIGID=A10A6A9C08E1&CUSTCODE=#{purchase.id}&VERBOSITY=HIGH&",
               :headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => successful_response, :headers => {})
      end
      
      it "returns a hash with a RESULT key with value 0" do
        expect(response["RESULT"]).to eq("0")
      end
      it "returns a hash with a RESPMSG key" do
        expect(response["RESPMSG"]).to eq("Approved")
      end
      
    end
    
    context "the transaction was denied" do
      before do
        failed_response = "RESULT=23&PNREF=A1X06A9C2A6B&RESPMSG=Invalid account number"
        stub_request(:post, "https://pilot-payflowpro.paypal.com/").
          with(:body => "TRXTYPE=A&TENDER=C&USER=leeandlow257&PWD=stardate?652&VENDOR=leeandlow257&PARTNER=PaypalPayflowApi::Paypal&AMT=999.0&ORIGID=A10A6A9C08E1&CUSTCODE=#{purchase.id}&VERBOSITY=HIGH&",
               :headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => failed_response, :headers => {})
      end
      
      it "returns a hash with a RESULT key with value != 0" do
        expect(response["RESULT"]).not_to eq("0")
      end
      it "returns a hash with a RESPMSG key with value != Approved" do
        expect(response["RESPMSG"]).not_to eq("Approved")
      end
    end
  end
  
  describe "#verify_billing_info" do
    let(:billing_address) { FactoryGirl.create(:address) }
    let(:purchase) { FactoryGirl.create(:purchase, bill_addr_id: billing_address.id, total_price: 999.00) }
    let(:response) {
      credit_card = {"acct"=>"5105105105105100", "expmmyy"=>"1215", "cvv" => "123"}
      paypal = PaypalPayflowApi::Paypal.new(purchase: purchase, credit_card: credit_card)        
      paypal.verify_billing_info
    }
    
    context "the CVV does not match" do
      before do
        failed_response = "RESULT=0&PNREF=A11A6A935B5F&RESPMSG=Verified&AUTHCODE=571PNI&AVSADDR=X&AVSZIP=X&CVV2MATCH=N&HOSTCODE=A&PROCAVS=U&PROCCVV2=M&TRANSTIME=2014-01-30 08:31:22&FIRSTNAME=net&LASTNAME=theory&AMT=0.00&ACCT=5100&EXPDATE=1215&CARDTYPE=1&IAVS=X"
        stub_request(:post, "https://pilot-payflowpro.paypal.com/").
          with(:body => "TRXTYPE=A&TENDER=C&USER=leeandlow257&PWD=stardate?652&VENDOR=leeandlow257&PARTNER=PaypalPayflowApi::Paypal&AMT=0.0&ACCT=5105105105105100&EXPDATE=1215&CVV2=123&FIRSTNAME=Nettheory&LASTNAME=address&STREET=Nettheory addressSuite 3000&CITY=Nettheory City address&STATE=NY&ZIP=5458482&CUSTCODE=#{purchase.id}&VERBOSITY=HIGH&",
               :headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => failed_response, :headers => {})


      end
      
      it "returns a hash with a CVV2MATCH key with value 'N'" do
        expect(response['CVV2MATCH']).to eq("N")
      end
    end
    
    context "the address is invalid" do
      before do
        failed_response = "RESULT=0&PNREF=A11A6A935B5F&RESPMSG=Verified&AUTHCODE=571PNI&AVSADDR=N&AVSZIP=N&CVV2MATCH=Y&HOSTCODE=A&PROCAVS=U&PROCCVV2=M&TRANSTIME=2014-01-30 08:31:22&FIRSTNAME=net&LASTNAME=theory&AMT=0.00&ACCT=5100&EXPDATE=1215&CARDTYPE=1&IAVS=X"
        stub_request(:post, "https://pilot-payflowpro.paypal.com/").
          with(:body => "TRXTYPE=A&TENDER=C&USER=leeandlow257&PWD=stardate?652&VENDOR=leeandlow257&PARTNER=PaypalPayflowApi::Paypal&AMT=0.0&ACCT=5105105105105100&EXPDATE=1215&CVV2=123&FIRSTNAME=Nettheory&LASTNAME=address&STREET=Nettheory addressSuite 3000&CITY=Nettheory City address&STATE=NY&ZIP=5458482&CUSTCODE=#{purchase.id}&VERBOSITY=HIGH&",
               :headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => failed_response, :headers => {})
      end
      
      it "returns a hash with a AVSADDR key with value 'N'" do
        expect(response['AVSADDR']).to eq("N")
      end
      
      it "returns a hash with a AVSZIP key with value 'N'" do
        expect(response['AVSZIP']).to eq("N")
      end
    end
    
    context "the address and CC are verified" do 
      before do
        successful_response = "RESULT=0&PNREF=A71A5F4CDF90&RESPMSG=Verified&AUTHCODE=153PNI&AVSADDR=Y&AVSZIP=Y&CVV2MATCH=Y&HOSTCODE=A&PROCAVS=Y&PROCCVV2=M&TRANSTIME=2014-01-30 06:55:25&FIRSTNAME=net&LASTNAME=theory&AMT=0.00&ACCT=5100&EXPDATE=1215&CARDTYPE=1&IAVS=N"
        stub_request(:post, "https://pilot-payflowpro.paypal.com/").
          with(:body => "TRXTYPE=A&TENDER=C&USER=leeandlow257&PWD=stardate?652&VENDOR=leeandlow257&PARTNER=PaypalPayflowApi::Paypal&AMT=0.0&ACCT=5105105105105100&EXPDATE=1215&CVV2=123&FIRSTNAME=Nettheory&LASTNAME=address&STREET=Nettheory addressSuite 3000&CITY=Nettheory City address&STATE=NY&ZIP=5458482&CUSTCODE=#{purchase.id}&VERBOSITY=HIGH&",
               :headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => successful_response, :headers => {})

      end
      
      it "returns a hash with a RESULT key with value '0'" do
        expect(response['RESULT']).to eq("0")
      end
      
      it "returns a hash with a RESPMSG key with value 'Verified'" do
        expect(response['RESPMSG']).to eq("Verified")
      end
      
      it "returns a hash with a PNREF key" do
        expect(response['PNREF']).not_to be_blank
      end
      
      it "returns a hash with a AVSADDR key" do
        expect(response['AVSADDR']).to eq("Y")
      end
      
      it "returns a hash with a AVSZIP key" do
        expect(response['AVSZIP']).to eq("Y")
      end
      
      it "returns a hash with a CVV2MATCH key" do
        expect(response['CVV2MATCH']).to eq("Y")
      end
    end
    
  end
  
  
end