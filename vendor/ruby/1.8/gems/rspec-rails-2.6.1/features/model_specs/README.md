Model specs live in `spec/models` or any example group with
`:type => :model`.

A model spec is a thin wrapper for an ActiveSupport::TestCase, and includes all
of the behavior and assertions that it provides, in addition to RSpec's own
behavior and expectations.

## Examples

    require "spec_helper"
    
    describe Post do
      context "with 2 or more comments" do
        it "orders them in reverse" do
          post = Post.create
          comment1 = post.comment("first")
          comment2 = post.comment("second")
          post.reload.comments.should eq([comment2, comment1])
        end
      end
    end
