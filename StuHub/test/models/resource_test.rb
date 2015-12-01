require 'test_helper'

class ResourceTest < ActiveSupport::TestCase

  def setup
    @resource = Resource.new(name: "Test Resource", description: "A Test Resource",
                        file_name: "test123.pdf", content_type: "application/pdf")
  end

  test "should be valid" do
    @resource.valid?
  end

  test "name should be present" do
    @resource.name = ""
    assert_not @resource.valid?
  end

  test "description should be present" do
    @resource.description = ""
    assert_not @resource.valid?
  end

  test "file_name should be present" do
    @resource.file_name = ""
    assert_not @resource.valid?
  end

  test "content_type should be present" do
    @resource.content_type = ""
    assert_not @resource.valid?
  end

  test "content_type should be valid" do
    @resource.content_type = "application/exe"
    assert_not @resource.valid?
  end

  test "file_type_string should get correct type" do
    @resource.content_type = "image/jpeg"
    assert_equal "JPEG", @resource.file_type_string
    @resource.content_type = "image/png"
    assert_equal "PNG", @resource.file_type_string
    @resource.content_type = "image/gif"
    assert_equal "GIF", @resource.file_type_string
    @resource.content_type = "image/svg"
    assert_equal "Unknown", @resource.file_type_string

    @resource.content_type = "application/pdf"
    assert_equal "PDF", @resource.file_type_string

    @resource.content_type = "application/vnd.ms-excel"
    assert_equal "Excel", @resource.file_type_string
    @resource.content_type = "application/msword"
    assert_equal "Word", @resource.file_type_string
    @resource.content_type = "application/vnd.ms-powerpoint"
    assert_equal "Powerpoint", @resource.file_type_string

    @resource.content_type = "text/plain"
    assert_equal "Text", @resource.file_type_string
    @resource.content_type = "application/rtf"
    assert_equal "Text", @resource.file_type_string
    @resource.content_type = "application/exe"
    assert_equal "Unknown", @resource.file_type_string
  end
end
