require 'spec_helper'

describe TemplatePicker do
  before do
    @post_stubs = {:type => 'StatusMessage', :photos => stub(:size => 2), 
                   :o_embed_cache => stub(:present? => true), 
                   :text? => true, :text => stub(:length => 400)
                  }
  end

  let(:post) {
    stub(@post_stubs)
  }

  it 'has a post' do
    t = TemplatePicker.new(post)
    t.post.should_not be_nil
  end

  describe '#template_name' do
    it 'returns the coolest template if the post has lots of cool stuff' do
      TemplatePicker.new(post).template_name.should_not be_nil
    end
  end

  describe '#status_with_photo_backdrop?' do
    it 'is false even if the post contains a single photo and text' do
      @post_stubs.merge!(:photos => stub(:size => 1))
      TemplatePicker.new(post).should_not be_status_with_photo_backdrop
    end
  end

  describe '#note?' do
    it 'is true if the post contains text more than 300 characters long' do
      TemplatePicker.new(post).should be_note
    end
  end

  describe '#photo_backdrop?' do
    it 'is false even if the post contains only one photo' do
      @post_stubs.merge!(:photos => stub(:size => 1))
      TemplatePicker.new(post).should_not be_photo_backdrop
    end

  end

  describe '#status?' do
    it 'is true if the post contains text' do
      TemplatePicker.new(post).should be_status
    end
  end

  describe 'factories' do
    # No photo_backdrop for now.
    (TemplatePicker::TEMPLATES - ['status_with_photo_backdrop', 'photo_backdrop']).each do |template|
      describe "#{template} factory" do
        it 'works' do
          post = FactoryGirl.build(template.to_sym, :author => alice.person)
          template_name = TemplatePicker.new(post).template_name.gsub('-', '_')
          template_name.should == template
        end
      end
    end
  end

end
