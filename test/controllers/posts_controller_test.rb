require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:post_to_everyone)
    sign_in_as_admin
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get index for vistor" do
    sign_out

    get posts_url
    assert_response :success
  end

  test "should get index for member" do
    sign_out

    @member = members(:member)
    @member.team = Team.create!(name: "TeamOne")
    @member.save!
    sign_in_as_member(@member)

    get posts_url
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    assert_difference('Post.count') do
      post posts_url, params: { post: { description: @post.description, restriction: @post.restriction, title: @post.title } }
    end

    assert_redirected_to post_path(Post.last)
  end

  test "should show post" do
    get post_url(@post)
    assert_response :success
  end

  test "should get edit" do
    get edit_post_url(@post)
    assert_response :success
  end

  test "should update post" do
    patch post_url(@post), params: { post: { description: @post.description, restriction: @post.restriction, title: @post.title } }
    assert_redirected_to post_path(@post)
  end

  test "should destroy post" do
    assert_difference('Post.count', -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_path
  end

  test "show redirect vistor to sigin in page if post is restricted" do
    sign_out
    post_for_member = posts(:post_to_member)

    get post_url(post_for_member)
    assert_redirected_to signin_path(from: (post_path(post_for_member)))

    get post_url(post_for_member) + "?foo=bar"
    assert_redirected_to signin_path(from: (post_path(post_for_member) + "?foo=bar"))

    get post_url(post_for_member) + "?from=%2Fposts"
    assert_redirected_to signin_path(from: post_path(post_for_member))
  end
end
