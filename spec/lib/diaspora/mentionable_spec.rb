
require 'spec_helper'

describe Diaspora::Mentionable do
  include PeopleHelper

  before do
    @people = [alice, bob, eve].map(&:person)
    @test_txt = <<-STR
This post contains a lot of mentions
one @{Alice A; #{@people[0].diaspora_handle}},
two @{Bob B; #{@people[1].diaspora_handle}} and finally
three @{"Eve> E; #{@people[2].diaspora_handle}}.
STR
    @test_txt_plain = <<-STR
This post contains a lot of mentions
one Alice A,
two Bob B and finally
three &quot;Eve&gt; E.
STR
    @status_msg = FactoryGirl.build(:status_message, text: @test_txt)
  end

  describe '#format' do
    context 'html output' do
      it 'adds the links to the formatted message' do
        fmt_msg = Diaspora::Mentionable.format(@status_msg.raw_message, @people)

        @people.each do |person|
          fmt_msg.should include person_link(person, class: 'mention hovercardable')
        end
      end

      it 'should work correct when message is escaped html' do
        raw_msg = @status_msg.raw_message
        fmt_msg = Diaspora::Mentionable.format(CGI::escapeHTML(raw_msg), @people)

        @people.each do |person|
          fmt_msg.should include person_link(person, class: 'mention hovercardable')
        end
      end

      it 'escapes the link title (name)' do
        p = @people[0].profile
        p.first_name = "</a><script>alert('h')</script>"
        p.save!

        fmt_msg = Diaspora::Mentionable.format(@status_msg.raw_message, @people)

        fmt_msg.should_not include(p.first_name)
        fmt_msg.should include("&gt;", "&lt;", "&#39;") # ">", "<", "'"
      end
    end

    context 'plain text output' do
      it 'removes mention markup and displays unformatted name' do
        fmt_msg = Diaspora::Mentionable.format(@status_msg.raw_message, @people, plain_text: true)

        @people.each do |person|
          fmt_msg.should include person.first_name
        end
        fmt_msg.should_not include "<a", "</a>", "hovercardable"
      end
    end

    it 'leaves the name of people that cannot be found' do
      fmt_msg = Diaspora::Mentionable.format(@status_msg.raw_message, [])
      fmt_msg.should eql @test_txt_plain
    end
  end

  describe '#people_from_string' do
    it 'extracts the mentioned people from the text' do
      ppl = Diaspora::Mentionable.people_from_string(@test_txt)
      ppl.should include(*@people)
    end

    describe 'returns an empty array if nobody was found' do
      it 'gets a post without mentions' do
        ppl = Diaspora::Mentionable.people_from_string("post w/o mentions")
        ppl.should be_empty
      end

      it 'gets a post with invalid handles' do
        ppl = Diaspora::Mentionable.people_from_string("@{a; xxx@xxx.xx} @{b; yyy@yyyy.yyy}")
        ppl.should be_empty
      end
    end
  end

  describe '#filter_for_aspects' do
    before do
      @user_A = FactoryGirl.create(:user_with_aspect, :username => "user_a")
      @user_B = FactoryGirl.create(:user, :username => "user_b")
      @user_C = FactoryGirl.create(:user, :username => "user_c")

      @user_A.aspects.create!(name: 'second')

      @mention_B = "@{user B; #{@user_B.diaspora_handle}}"
      @mention_C = "@{user C; #{@user_C.diaspora_handle}}"

      @user_A.share_with(@user_B.person, @user_A.aspects.where(name: 'generic'))
      @user_A.share_with(@user_C.person, @user_A.aspects.where(name: 'second'))

      @test_txt_B = "mentioning #{@mention_B}"
      @test_txt_C = "mentioning #{@mention_C}"
      @test_txt_BC = "mentioning #{@mention_B}} and #{@mention_C}"
    end

    it 'filters mention, if contact is not in a given aspect' do
      aspect_id = @user_A.aspects.where(name: 'generic').first.id
      txt = Diaspora::Mentionable.filter_for_aspects(@test_txt_C, @user_A, aspect_id)

      txt.should include(@user_C.person.name)
      txt.should include(local_or_remote_person_path(@user_C.person))
      txt.should_not include("href")
      txt.should_not include(@mention_C)
    end

    it 'leaves mention, if contact is in a given aspect' do
      aspect_id = @user_A.aspects.where(name: 'generic').first.id
      txt = Diaspora::Mentionable.filter_for_aspects(@test_txt_B, @user_A, aspect_id)

      txt.should include("user B")
      txt.should include(@mention_B)
    end

    it 'recognizes "all" as keyword for aspects' do
      txt = Diaspora::Mentionable.filter_for_aspects(@test_txt_BC, @user_A, "all")

      txt.should include(@mention_B)
      txt.should include(@mention_C)
    end
  end
end
