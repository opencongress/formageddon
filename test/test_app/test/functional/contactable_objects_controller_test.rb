require 'test_helper'

class ContactableObjectsControllerTest < ActionController::TestCase
  setup do
    @contactable_object = contactable_objects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contactable_objects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contactable_object" do
    assert_difference('ContactableObject.count') do
      post :create, :contactable_object => @contactable_object.attributes
    end

    assert_redirected_to contactable_object_path(assigns(:contactable_object))
  end

  test "should show contactable_object" do
    get :show, :id => @contactable_object.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @contactable_object.to_param
    assert_response :success
  end

  test "should update contactable_object" do
    put :update, :id => @contactable_object.to_param, :contactable_object => @contactable_object.attributes
    assert_redirected_to contactable_object_path(assigns(:contactable_object))
  end

  test "should destroy contactable_object" do
    assert_difference('ContactableObject.count', -1) do
      delete :destroy, :id => @contactable_object.to_param
    end

    assert_redirected_to contactable_objects_path
  end
end
