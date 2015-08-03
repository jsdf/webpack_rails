require 'webpack_rails'

RSpec.describe WebpackRails::Task do
  after(:each) do
    WebpackRails::Task.release
  end

  it "spawns a node server" do
    server = WebpackRails::Task.server
  end

  it "runs webpack" do
    result = WebpackRails::Task.run_webpack
    expect(result).not_to be_nil
  end
end
