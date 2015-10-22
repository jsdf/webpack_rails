require 'rails_helper'

RSpec.describe "webpack sprockets rails integration", :type => :request do
  it "builds successfully" do
    get "/assets/application.js"

    expect(response.body).to include('PostsScreen')
  end
end
