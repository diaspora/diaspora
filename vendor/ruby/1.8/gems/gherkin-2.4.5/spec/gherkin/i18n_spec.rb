#encoding: utf-8
require 'spec_helper'

module Gherkin
  module Lexer
    describe I18n do
      before do
        @listener = Gherkin::SexpRecorder.new
      end

      def scan_file(lexer, file)
        lexer.scan(File.new(File.dirname(__FILE__) + "/fixtures/" + file).read)
      end

      it "should recognize keywords in the language of the lexer" do
        lexer = Gherkin::Lexer::I18nLexer.new(@listener, false)
        scan_file(lexer, "i18n_no.feature")
        @listener.to_sexp.should == [
          [:comment, "#language:no", 1],
          [:feature, "Egenskap", "i18n support", "", 2],
          [:scenario, "Scenario", "Parsing many languages", "", 4],
          [:step, "Gitt ", "Gherkin supports many languages", 5],
          [:step, "Når ",  "Norwegian keywords are parsed", 6],
          [:step, "Så ", "they should be recognized", 7],
          [:eof]
        ]
      end

      it "should parse languages without a space after keywords" do
        lexer = Gherkin::Lexer::I18nLexer.new(@listener, false)
        scan_file(lexer, "i18n_zh-CN.feature")
        @listener.to_sexp.should == [
          [:comment, "#language:zh-CN", 1],
          [:feature, "功能", "加法", "", 2],
          [:scenario, "场景", "两个数相加", "", 4],
          [:step, "假如", "我已经在计算器里输入6", 5],
          [:step, "而且", "我已经在计算器里输入7", 6],
          [:step, "当", "我按相加按钮", 7],
          [:step, "那么", "我应该在屏幕上看到的结果是13", 8],
          [:eof]
        ] 
      end

      it "should parse languages with spaces after some keywords but not others" do
        lexer = Gherkin::Lexer::I18nLexer.new(@listener, false)
        scan_file(lexer, "i18n_fr.feature")
        @listener.to_sexp.should == [
          [:comment, "#language:fr", 1],
          [:feature, "Fonctionnalité", "Addition", "", 2],
          [:scenario_outline, "Plan du scénario", "Addition de produits dérivés", "", 3],
          [:step, "Soit ", "une calculatrice", 4],
          [:step, "Etant donné ", "qu'on tape <a>", 5],
          [:step, "Et ", "qu'on tape <b>", 6],
          [:step, "Lorsqu'", "on tape additionner", 7],
          [:step, "Alors ", "le résultat doit être <somme>", 8],
          [:examples, "Exemples", "", "", 10],
          [:row, %w{a b somme}, 11],
          [:row, %w{2 2 4}, 12],
          [:row, %w{2 3 5}, 13],
          [:eof]
        ]
      end

      describe 'keywords' do
        it "should have code keywords without space, comma, exclamation or apostrophe" do
          ['Avast', 'Akkor', 'Etantdonné', 'Lorsque', '假設'].each do |code_keyword|
            Gherkin::I18n.code_keywords.should include(code_keyword)
          end
        end

        it "should reject the bullet stars" do
          Gherkin::I18n.code_keywords.should_not include('*')
        end

        it "should report keyword regexp" do
          Gherkin::I18n.keyword_regexp(:step).should =~ /\|Quando \|Quand \|Quan \|Pryd \|Pokud \|/
        end

        unless defined?(JRUBY_VERSION)
        it "should print available languages" do
          ("\n" + Gherkin::I18n.language_table).should == %{
      | ar        | Arabic              | العربية           |
      | bg        | Bulgarian           | български         |
      | ca        | Catalan             | català            |
      | cs        | Czech               | Česky             |
      | cy-GB     | Welsh               | Cymraeg           |
      | da        | Danish              | dansk             |
      | de        | German              | Deutsch           |
      | en        | English             | English           |
      | en-Scouse | Scouse              | Scouse            |
      | en-au     | Australian          | Australian        |
      | en-lol    | LOLCAT              | LOLCAT            |
      | en-pirate | Pirate              | Pirate            |
      | en-tx     | Texan               | Texan             |
      | eo        | Esperanto           | Esperanto         |
      | es        | Spanish             | español           |
      | et        | Estonian            | eesti keel        |
      | fi        | Finnish             | suomi             |
      | fr        | French              | français          |
      | he        | Hebrew              | עברית             |
      | hr        | Croatian            | hrvatski          |
      | hu        | Hungarian           | magyar            |
      | id        | Indonesian          | Bahasa Indonesia  |
      | it        | Italian             | italiano          |
      | ja        | Japanese            | 日本語               |
      | ko        | Korean              | 한국어               |
      | lt        | Lithuanian          | lietuvių kalba    |
      | lu        | Luxemburgish        | Lëtzebuergesch    |
      | lv        | Latvian             | latviešu          |
      | nl        | Dutch               | Nederlands        |
      | no        | Norwegian           | norsk             |
      | pl        | Polish              | polski            |
      | pt        | Portuguese          | português         |
      | ro        | Romanian            | română            |
      | ru        | Russian             | русский           |
      | sk        | Slovak              | Slovensky         |
      | sr-Cyrl   | Serbian             | Српски            |
      | sr-Latn   | Serbian (Latin)     | Srpski (Latinica) |
      | sv        | Swedish             | Svenska           |
      | tr        | Turkish             | Türkçe            |
      | uk        | Ukrainian           | Українська        |
      | uz        | Uzbek               | Узбекча           |
      | vi        | Vietnamese          | Tiếng Việt        |
      | zh-CN     | Chinese simplified  | 简体中文              |
      | zh-TW     | Chinese traditional | 繁體中文              |
}
        end
        end

        it "should print keywords for a given language" do
          ("\n" + Gherkin::I18n.get('fr').keyword_table).should == %{
      | feature          | "Fonctionnalité"                       |
      | background       | "Contexte"                             |
      | scenario         | "Scénario"                             |
      | scenario_outline | "Plan du scénario", "Plan du Scénario" |
      | examples         | "Exemples"                             |
      | given            | "* ", "Soit ", "Etant donné "          |
      | when             | "* ", "Quand ", "Lorsque ", "Lorsqu'"  |
      | then             | "* ", "Alors "                         |
      | and              | "* ", "Et "                            |
      | but              | "* ", "Mais "                          |
      | given (code)     | "Soit", "Etantdonné"                   |
      | when (code)      | "Quand", "Lorsque", "Lorsqu"           |
      | then (code)      | "Alors"                                |
      | and (code)       | "Et"                                   |
      | but (code)       | "Mais"                                 |
}
        end
      end
    end
  end
end
