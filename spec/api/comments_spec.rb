require 'spec_helper'
require 'active_support/core_ext'

describe API::V3, "comments", :type => :request do
  describe "POST /api/v3/comments/create.json" do
    it "should return true" do
      post "/api/v3/comments/create.json", mac: "dd:df:33:33", channel: "cctv-1", body: "here we go"
      expect(response.status).to eq(201)
      expect(response.body).to eq('{"result":true}')
    end
  end

  describe "POST /api/v3/comments/create.json" do
    it "should post a new comment" do
      expect { post "/api/v3/comments/create.json", mac: "dd:df:33:33", channel: "cctv-1", body: "here we go"}.to change(Comment, :count)
    end
  end

  describe "GET /api/v3/comments/select.json" do
    let (:comment) { FactoryGirl.create(:comment) }
    it "should return comments" do
      get "/api/v3/comments/select.json?channel=#{comment.channel}&&limit=1"
      expect(response.status).to eq(200)
      expect(response.body).to match(/true/)
    end
  end
end

