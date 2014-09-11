require "test_helper"

class ProductTest < ActiveSupport::TestCase

  def setup
    @product = create(:product)
  end

  test "should create product" do
    assert_not_nil @product
  end

  test "should respond to hot?" do
    assert_respond_to @product, :hot?
  end

  test "shoud have name and price and desctiption" do
    assert_not_nil @product.name
    assert_not_nil @product.price
    assert_not_nil @product.description
  end

end
