require "spec_helper"

context "when provision finishes" do
  describe server(:sensu1) do
    let(:json) { JSON.parse(response.body) }
    base_uri = "http://127.0.0.1:4567"

    describe http("#{base_uri}/health") do
      it "reports queue status is ok" do
        expect(response.status).to eq 204
      end
    end

    describe http("#{base_uri}/clients") do
      it "returns JSON" do
        expect { JSON.parse(response.body) }.not_to raise_error
      end

      it "returns two clients" do
        expect(json.length).to eq 2
      end

      it "contains sensu1.virtualbox.reallyenglish.com" do
        expect(json).to include(include("name" => "sensu1.virtualbox.reallyenglish.com"))
      end

      it "contains client1.virtualbox.reallyenglish.com" do
        expect(json).to include(include("name" => "client1.virtualbox.reallyenglish.com"))
      end
    end

    describe http("#{base_uri}/checks") do
      it "returns JSON" do
        expect { JSON.parse(response.body) }.not_to raise_error
      end

      it "returns one check" do
        expect(json.length).to eq 1
      end

      it "contains check-load.rb" do
        expect(json.first["command"]).to eq "check-load.rb"
      end
    end
  end
end
