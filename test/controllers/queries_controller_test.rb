require 'test_helper'

module Collector
  class QueriesControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    setup do
      @query = queries(:one)
      @request.env['devise.mapping'] = Devise.mappings[:admin]
    end

    test 'should get index' do
      get :index
      assert_response :success
      assert_not_nil assigns(:queries)
    end

    test 'should get new' do
      get :new
      assert_response :success
    end

    test 'should create query' do
      assert_difference('Query.count') do
        post :create, query: { executed: @query.executed, text: @query.text }
      end

      assert_redirected_to collector_query_path(assigns(:query))
    end

    test 'should show query' do
      get :show, id: @query
      assert_response :success
    end

    test 'should get edit' do
      get :edit, id: @query
      assert_response :success
    end

    test 'should update query' do
      patch :update, id: @query, query: { executed: @query.executed, text: @query.text }
      assert_redirected_to collector_query_path(assigns(:query))
    end

    test 'should destroy query' do
      assert_difference('Query.count', -1) do
        delete :destroy, id: @query
      end

      assert_redirected_to collector_queries_path
    end
  end
end
