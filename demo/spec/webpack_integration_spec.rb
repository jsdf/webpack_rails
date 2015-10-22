require 'rails_helper'

RSpec.describe "webpack bundle", :type => :request do
  it "builds successfully" do
    get "/assets/application.js"

    expect(response.body).to include(%{document.write('<script src="http://localhost:9876/posts.bundle.js"></script>');})
  end
end
