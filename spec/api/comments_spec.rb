require 'rails_helper'
require 'active_support/core_ext'

describe API::V3, "comments", :type => :request do
  describe "POST /api/v3/comments/create.json" do
    it "should post a new comment" do
      post "/api/v3/comments/create.json", mac: "dd:df:33:33", channel: "cctv-1", body: "here we go"
      expect(response.status).to eq(201)
    end
  end
end

