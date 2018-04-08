# frozen_string_literal: true

describe Diaspora::Mentionable do
  include PeopleHelper

  let(:people) { [alice, bob, eve].map(&:person) }
  let(:names) { %w(Alice\ A Bob\ B "Eve>\ E) }

  let(:test_text_with_names) { <<-STR }
This post contains a lot of mentions
one @{#{names[0]}; #{people[0].diaspora_handle}},
two @{#{names[1]}; #{people[1].diaspora_handle}} and finally
three @{#{names[2]}; #{people[2].diaspora_handle}}.
STR

  let(:test_text_without_names) { <<-STR }
This post contains a lot of mentions
one @{#{people[0].diaspora_handle}},
two @{#{people[1].diaspora_handle}} and finally
three @{#{people[2].diaspora_handle}}.
STR

  describe ".mention_attrs" do
    it "returns name and diaspora ID" do
      name, diaspora_id = Diaspora::Mentionable.mention_attrs("@{#{names[0]}; #{people[0].diaspora_handle}}")
      expect(name).to eq(names[0])
      expect(diaspora_id).to eq(people[0].diaspora_handle)
    end

    it "returns only diaspora-ID when no name is included" do
      name, diaspora_id = Diaspora::Mentionable.mention_attrs("@{#{people[0].diaspora_handle}}")
      expect(diaspora_id).to eq(people[0].diaspora_handle)
      expect(name).to be_nil
    end

    it "trims the name if available" do
      name, diaspora_id = Diaspora::Mentionable.mention_attrs("@{#{names[0]} ; #{people[0].diaspora_handle}}")
      expect(name).to eq(names[0])
      expect(diaspora_id).to eq(people[0].diaspora_handle)
    end
  end

  describe ".format" do
    context "html output" do
      it "adds the links to the formatted message" do
        fmt_msg = Diaspora::Mentionable.format(test_text_with_names, people)

        [people, names].transpose.each do |person, name|
          link = person_link(person, class: "mention hovercardable", display_name: name)
          expect(fmt_msg).to include "@#{link}"
        end
      end

      it "adds the links to the formatted message and uses the names from the people" do
        fmt_msg = Diaspora::Mentionable.format(test_text_without_names, people)

        people.each do |person|
          link = person_link(person, class: "mention hovercardable", display_name: person.name)
          expect(fmt_msg).to include "@#{link}"
        end
      end

      it "should work correct when message is escaped html" do
        fmt_msg = Diaspora::Mentionable.format(CGI.escapeHTML(test_text_with_names), people)

        [people, names].transpose.each do |person, name|
          expect(fmt_msg).to include person_link(person, class: "mention hovercardable", display_name: name)
        end
      end

      it "escapes the link title (name)" do
        name = "</a><script>alert('h')</script>"
        test_txt = "two @{#{name}; #{people[0].diaspora_handle}} and finally"

        fmt_msg = Diaspora::Mentionable.format(test_txt, people)

        expect(fmt_msg).not_to include(name)
        expect(fmt_msg).to include("&gt;", "&lt;", "&#39;") # ">", "<", "'"
      end
    end

    context "plain text output" do
      it "removes mention markup and displays unformatted name" do
        fmt_msg = Diaspora::Mentionable.format(test_text_with_names, people, plain_text: true)

        names.each do |name|
          expect(fmt_msg).to include "@#{CGI.escapeHTML(name)}"
        end
        expect(fmt_msg).not_to include "<a", "</a>", "hovercardable"
      end
    end

    it "leaves the names of people that cannot be found" do
      test_txt_plain = <<-STR
This post contains a lot of mentions
one @Alice A,
two @Bob B and finally
three @&quot;Eve&gt; E.
STR

      fmt_msg = Diaspora::Mentionable.format(test_text_with_names, [])
      expect(fmt_msg).to eql test_txt_plain
    end

    it "uses the diaspora ID when the person cannot be found" do
      test_txt_plain = <<-STR
This post contains a lot of mentions
one @#{people[0].diaspora_handle},
two @#{people[1].diaspora_handle} and finally
three @#{people[2].diaspora_handle}.
STR

      fmt_msg = Diaspora::Mentionable.format(test_text_without_names, [])
      expect(fmt_msg).to eql test_txt_plain
    end
  end

  describe ".people_from_string" do
    it "extracts the mentioned people from the text" do
      ppl = Diaspora::Mentionable.people_from_string(test_text_with_names)
      expect(ppl).to match_array(people)
    end

    it "extracts the mentioned people from the text without name" do
      text = "test @{#{people[0].diaspora_handle}} test"
      ppl = Diaspora::Mentionable.people_from_string(text)
      expect(ppl).to match_array([people[0]])
    end

    it "extracts the mentioned people from the text mixed mentions (with and without name)" do
      text = "@{#{people[0].diaspora_handle}} and @{#{names[1]}; #{people[1].diaspora_handle}}"
      ppl = Diaspora::Mentionable.people_from_string(text)
      expect(ppl).to match_array([people[0], people[1]])
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

  describe ".filter_people" do
    let(:user_a) { FactoryGirl.create(:user_with_aspect, username: "user_a") }
    let(:user_b) { FactoryGirl.create(:user, username: "user_b") }
    let(:user_c) { FactoryGirl.create(:user, username: "user_c") }

    before do
      user_a.aspects.create!(name: "second")

      user_a.share_with(user_b.person, user_a.aspects.where(name: "generic"))
      user_a.share_with(user_c.person, user_a.aspects.where(name: "second"))
    end

    it "filters mention, if contact is not in a given aspect" do
      mention = "@{user C; #{user_c.diaspora_handle}}"
      txt = Diaspora::Mentionable.filter_people(
        "mentioning #{mention}",
        user_a.aspects.where(name: "generic").first.contacts.map(&:person_id)
      )

      expect(txt).to include("@[user C](#{local_or_remote_person_path(user_c.person)}")
      expect(txt).not_to include("href")
      expect(txt).not_to include(mention)
    end

    it "leaves mention, if contact is in a given aspect" do
      mention = "@{user B; #{user_b.diaspora_handle}}"
      txt = Diaspora::Mentionable.filter_people(
        "mentioning #{mention}",
        user_a.aspects.where(name: "generic").first.contacts.map(&:person_id)
      )

      expect(txt).to include("user B")
      expect(txt).to include(mention)
    end

    it "works if the person cannot be found" do
      expect(Person).to receive(:find_or_fetch_by_identifier).with("non_existing_user@example.org").and_return(nil)

      mention = "@{non_existing_user@example.org}"
      txt = Diaspora::Mentionable.filter_people("mentioning #{mention}", [])

      expect(txt).to eq "mentioning @non_existing_user@example.org"
    end
  end

  describe ".backport_mention_syntax" do
    it "replaces the new syntax with the old syntax" do
      text = "mention @{#{people[0].diaspora_handle}} text"
      expected_text = "mention @{#{people[0].name}; #{people[0].diaspora_handle}} text"
      expect(Diaspora::Mentionable.backport_mention_syntax(text)).to eq(expected_text)
    end

    it "replaces the new syntax with the old syntax for immediately consecutive mentions" do
      text = "mention @{#{people[0].diaspora_handle}}@{#{people[1].diaspora_handle}} text"
      expected_text = "mention @{#{people[0].name}; #{people[0].diaspora_handle}}" \
        "@{#{people[1].name}; #{people[1].diaspora_handle}} text"
      expect(Diaspora::Mentionable.backport_mention_syntax(text)).to eq(expected_text)
    end

    it "removes curly braces from name of the mentioned person when adding it" do
      profile = FactoryGirl.build(:profile, first_name: "{Alice}", last_name: "(Smith) [123]")
      person = FactoryGirl.create(:person, profile: profile)
      text = "mention @{#{person.diaspora_handle}} text"
      expected_text = "mention @{Alice (Smith) [123]; #{person.diaspora_handle}} text"
      expect(Diaspora::Mentionable.backport_mention_syntax(text)).to eq(expected_text)
    end

    it "does not change the text, when the mention includes a name" do
      text = "mention @{#{names[0]}; #{people[0].diaspora_handle}} text"
      expect(Diaspora::Mentionable.backport_mention_syntax(text)).to eq(text)
    end

    it "does not change the text, when the person is not found" do
      text = "mention @{non_existing_user@example.org} text"
      expect(Person).to receive(:find_or_fetch_by_identifier).with("non_existing_user@example.org").and_return(nil)
      expect(Diaspora::Mentionable.backport_mention_syntax(text)).to eq(text)
    end

    it "does not change the text, when the diaspora ID is invalid" do
      text = "mention @{invalid_diaspora_id} text"
      expect(Person).not_to receive(:find_or_fetch_by_identifier)
      expect(Diaspora::Mentionable.backport_mention_syntax(text)).to eq(text)
    end
  end
end
