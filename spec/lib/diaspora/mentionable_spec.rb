
require "spec_helper"

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

  describe "#format" do
    context "html output" do
      it "adds the links to the formatted message" do
        fmt_msg = Diaspora::Mentionable.format(@status_msg.text, @people)

        @people.each do |person|
          expect(fmt_msg).to include person_link(person, class: "mention hovercardable")
        end
      end

      it "should work correct when message is escaped html" do
        raw_msg = @status_msg.text
        fmt_msg = Diaspora::Mentionable.format(CGI.escapeHTML(raw_msg), @people)

        @people.each do |person|
          expect(fmt_msg).to include person_link(person, class: "mention hovercardable")
        end
      end

      it "escapes the link title (name)" do
        p = @people[0].profile
        p.first_name = "</a><script>alert('h')</script>"
        p.save!

        fmt_msg = Diaspora::Mentionable.format(@status_msg.text, @people)

        expect(fmt_msg).not_to include(p.first_name)
        expect(fmt_msg).to include("&gt;", "&lt;", "&#39;") # ">", "<", "'"
      end
    end

    context "plain text output" do
      it "removes mention markup and displays unformatted name" do
        fmt_msg = Diaspora::Mentionable.format(@status_msg.text, @people, plain_text: true)

        @people.each do |person|
          expect(fmt_msg).to include person.first_name
        end
        expect(fmt_msg).not_to include "<a", "</a>", "hovercardable"
      end
    end

    it "leaves the name of people that cannot be found" do
      fmt_msg = Diaspora::Mentionable.format(@status_msg.text, [])
      expect(fmt_msg).to eql @test_txt_plain
    end
  end

  describe "#people_from_string" do
    it "extracts the mentioned people from the text" do
      ppl = Diaspora::Mentionable.people_from_string(@test_txt)
      expect(ppl).to include(*@people)
    end

    describe "returns an empty array if nobody was found" do
      it "gets a post without mentions" do
        ppl = Diaspora::Mentionable.people_from_string("post w/o mentions")
        expect(ppl).to be_empty
      end

      it "gets a post with invalid handles" do
        ppl = Diaspora::Mentionable.people_from_string("@{a; xxx@xxx.xx} @{b; yyy@yyyy.yyy} @{...} @{bla; blubb}")
        expect(ppl).to be_empty
      end
    end
  end

  describe "#filter_for_aspects" do
    before do
      @user_a = FactoryGirl.create(:user_with_aspect, username: "user_a")
      @user_b = FactoryGirl.create(:user, username: "user_b")
      @user_c = FactoryGirl.create(:user, username: "user_c")

      @user_a.aspects.create!(name: "second")

      @mention_b = "@{user B; #{@user_b.diaspora_handle}}"
      @mention_c = "@{user C; #{@user_c.diaspora_handle}}"

      @user_a.share_with(@user_b.person, @user_a.aspects.where(name: "generic"))
      @user_a.share_with(@user_c.person, @user_a.aspects.where(name: "second"))

      @test_txt_b = "mentioning #{@mention_b}"
      @test_txt_c = "mentioning #{@mention_c}"
      @test_txt_bc = "mentioning #{@mention_b}} and #{@mention_c}"
    end

    it "filters mention, if contact is not in a given aspect" do
      aspect_id = @user_a.aspects.where(name: "generic").first.id
      txt = Diaspora::Mentionable.filter_for_aspects(@test_txt_c, @user_a, aspect_id)

      expect(txt).to include(@user_c.person.name)
      expect(txt).to include(local_or_remote_person_path(@user_c.person))
      expect(txt).not_to include("href")
      expect(txt).not_to include(@mention_c)
    end

    it "leaves mention, if contact is in a given aspect" do
      aspect_id = @user_a.aspects.where(name: "generic").first.id
      txt = Diaspora::Mentionable.filter_for_aspects(@test_txt_b, @user_a, aspect_id)

      expect(txt).to include("user B")
      expect(txt).to include(@mention_b)
    end

    it "recognizes 'all' as keyword for aspects" do
      txt = Diaspora::Mentionable.filter_for_aspects(@test_txt_bc, @user_a, "all")

      expect(txt).to include(@mention_b)
      expect(txt).to include(@mention_c)
    end
  end
end
