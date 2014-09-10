require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @product = create(:product)
  end

  test "should create product" do
    setup
    assert_not_nil @product
  end

  test "should respond to hot?" do
    setup
    assert_respond_to @product, :hot?
  end

  test "shoud have name and price and desctiption" do
    setup
    assert_not_nil @product.name
    assert_not_nil @product.price
    assert_not_nil @product.description
  end

end
