require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end

  test "profile stats" do
    log_in_as(@user)
    assert_redirected_to @user
    get root_path
    assert_match "following", response.body
    assert_match "followers", response.body
    get user_path(@other_user)
    assert_match "following", response.body
    assert_match "followers", response.body
    assert_select 'form input[value=Follow]'
    @user.follow(@other_user)
    @user.reload
    get user_path(@other_user)
    assert_select 'form input[value=Unfollow]'
  end
end
