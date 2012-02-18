require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'template_picker')

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
    it 'is true if the post contains a single photo and text' do
      @post_stubs.merge!(:photos => stub(:size => 1))
      TemplatePicker.new(post).should be_status_with_photo_backdrop
    end
  end

  describe '#note?' do
    it 'is true if the post contains text more than 300 characters long' do
      TemplatePicker.new(post).should be_note
    end
  end

  describe '#rich_media?' do
    it 'is true if the post contains an o_embed object' do
      TemplatePicker.new(post).should be_rich_media
    end
  end

  describe 'multi_photo?' do
    it 'is true if the post contains more than one photo' do
      TemplatePicker.new(post).should be_multi_photo
    end
  end

  describe '#photo_backdrop?' do
    it 'is true if the post contains only one photo' do
      @post_stubs.merge!(:photos => stub(:size => 1))
      TemplatePicker.new(post).should be_photo_backdrop
    end

  end

  describe '#status?' do
    it 'is true if the post contains text' do
      TemplatePicker.new(post).should be_status
    end
  end
end