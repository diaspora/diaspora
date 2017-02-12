describe Diaspora::Mentionable do
  include PeopleHelper

  before do
    @people = [alice, bob, eve].map(&:person)
    @names = %w(Alice\ A Bob\ B "Eve>\ E)
    @test_txt = <<-STR
This post contains a lot of mentions
one @{#{@names[0]}; #{@people[0].diaspora_handle}},
two @{#{@names[1]}; #{@people[1].diaspora_handle}} and finally
three @{#{@names[2]}; #{@people[2].diaspora_handle}}.
STR
    @test_txt_plain = <<-STR
This post contains a lot of mentions
one Alice A,
two Bob B and finally
three &quot;Eve&gt; E.
STR
  end

  describe "#format" do
    context "html output" do
      it "adds the links to the formatted message" do
        fmt_msg = Diaspora::Mentionable.format(@test_txt, @people)

        [@people, @names].transpose.each do |person, name|
          expect(fmt_msg).to include person_link(person, class: "mention hovercardable", display_name: name)
        end
      end

      it "should work correct when message is escaped html" do
        fmt_msg = Diaspora::Mentionable.format(CGI.escapeHTML(@test_txt), @people)

        [@people, @names].transpose.each do |person, name|
          expect(fmt_msg).to include person_link(person, class: "mention hovercardable", display_name: name)
        end
      end

      it "escapes the link title (name)" do
        name = "</a><script>alert('h')</script>"
        test_txt = "two @{#{name}; #{@people[0].diaspora_handle}} and finally"

        fmt_msg = Diaspora::Mentionable.format(test_txt, @people)

        expect(fmt_msg).not_to include(name)
        expect(fmt_msg).to include("&gt;", "&lt;", "&#39;") # ">", "<", "'"
      end
    end

    context "plain text output" do
      it "removes mention markup and displays unformatted name" do
        fmt_msg = Diaspora::Mentionable.format(@test_txt, @people, plain_text: true)

        @names.each do |name|
          expect(fmt_msg).to include CGI.escapeHTML(name)
        end
        expect(fmt_msg).not_to include "<a", "</a>", "hovercardable"
      end
    end

    it "leaves the names of people that cannot be found" do
      fmt_msg = Diaspora::Mentionable.format(@test_txt, [])
      expect(fmt_msg).to eql @test_txt_plain
    end
  end

  describe "#people_from_string" do
    it "extracts the mentioned people from the text" do
      ppl = Diaspora::Mentionable.people_from_string(@test_txt)
      expect(ppl).to match_array(@people)
    end

    describe "returns an empty array if nobody was found" do
      it "gets a post without mentions" do
        ppl = Diaspora::Mentionable.people_from_string("post w/o mentions")
        expect(ppl).to be_empty
      end

      it "gets a post with invalid handles" do
        ppl = Diaspora::Mentionable.people_from_string("@{...} @{bla; blubb}")
        expect(ppl).to be_empty
      end

      it "filters duplicate handles" do
        ppl = Diaspora::Mentionable.people_from_string("@{a; #{alice.diaspora_handle}} @{a; #{alice.diaspora_handle}}")
        expect(ppl).to eq([alice.person])
      end

      it "fetches unknown handles" do
        person = FactoryGirl.build(:person)
        expect(Person).to receive(:find_or_fetch_by_identifier).with("xxx@xxx.xx").and_return(person)
        ppl = Diaspora::Mentionable.people_from_string("@{a; xxx@xxx.xx}")
        expect(ppl).to eq([person])
      end

      it "handles DiscoveryError" do
        expect(Person).to receive(:find_or_fetch_by_identifier).with("yyy@yyy.yy")
          .and_raise(DiasporaFederation::Discovery::DiscoveryError)
        ppl = Diaspora::Mentionable.people_from_string("@{b; yyy@yyy.yy}")
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

      expect(txt).to include("user C")
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
