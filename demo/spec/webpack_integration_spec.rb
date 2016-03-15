require 'rails_helper'

RSpec.describe "webpack sprockets rails integration", :type => :request do
  it "builds successfully" do
    get "/posts"

    expect(response.body).to include('assets/posts.bundle')
  end
end
