require 'spec_helper'
require 'active_support/core_ext'

describe API::V3, "users", :type => :request do
  #do not known how to test because of use verify code that would send to mobile phone
  describe "POST /api/v3/users/signup.json" do
    # it "should return true" do
    #   post "/api/v3/users/signup.json", name: "kkk", mobile_number:
    #   expect(response.status).to eq(201)
    #   expect(response.body).to eq('{"result":true}')
    # end
  end

  describe "POST /api/v3/users/signin.json" do
    let (:user) { FactoryGirl.build(:user) }
    it "should return return user id" do
      user.save
      post '/api/v3/users/signin.json', signin: user.mobile_number, password: user.password
      expect(response.body).to match("true")
    end
  end
end


