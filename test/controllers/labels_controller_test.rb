require 'test_helper'

module Collector
  class LabelsControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    setup do
      @label = labels(:one)
      @request.env['devise.mapping'] = Devise.mappings[:admin]
    end

    test 'should get index' do
      get :index
      assert_response :success
      assert_not_nil assigns(:labels)
    end

    test 'should get new' do
      get :new
      assert_response :success
    end

    test 'should create label' do
      assert_difference('Label.count') do
        post :create, label: { name: @label.name, tags: @label.tags }
      end

      assert_redirected_to collector_label_path(assigns(:label))
    end

    test 'should show label' do
      get :show, id: @label
      assert_response :success
    end

    test 'should get edit' do
      get :edit, id: @label
      assert_response :success
    end

    test 'should update label' do
      patch :update, id: @label, label: { name: @label.name, tags: @label.tags }
      assert_redirected_to collector_label_path(assigns(:label))
    end

    test 'should destroy label' do
      assert_difference('Label.count', -1) do
        delete :destroy, id: @label
      end

      assert_redirected_to collector_labels_path
    end
  end
end
