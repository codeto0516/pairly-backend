# test/firebase_storage_test.rb

require 'rails_helper'  # もしくは require 'spec_helper' for RSpec
require './lib/firebase/storage'

describe Firebase::Storage do
  before do
    # テストの前処理を行う場合、ここで初期化などを行うことができます
  end

  # it "should get files" do
  #   files = Firebase::Storage.get("ycuhTJw6V3grfkMudUW1taJnTzI3")
  #   expect(files).not_to be_empty
  # end

  it "should do something else" do
    Firebase::Storage.upload("ycuhTJw6V3grfkMudUW1taJnTzI3", "./public/test2.jpg")
  end
end
