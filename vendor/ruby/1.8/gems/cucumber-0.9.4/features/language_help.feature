@needs-many-fonts
Feature: Language help
  In order to figure out the keywords to use for a language
  I want to be able to get help on the language from the CLI

  Scenario: Get help for Portuguese language
    When I run cucumber --i18n pt help
    Then it should pass with
      """
            | feature          | "Funcionalidade"                           |
            | background       | "Contexto"                                 |
            | scenario         | "Cenário", "Cenario"                       |
            | scenario_outline | "Esquema do Cenário", "Esquema do Cenario" |
            | examples         | "Exemplos"                                 |
            | given            | "* ", "Dado "                              |
            | when             | "* ", "Quando "                            |
            | then             | "* ", "Então ", "Entao "                   |
            | and              | "* ", "E "                                 |
            | but              | "* ", "Mas "                               |
            | given (code)     | "Dado"                                     |
            | when (code)      | "Quando"                                   |
            | then (code)      | "Então", "Entao"                           |
            | and (code)       | "E"                                        |
            | but (code)       | "Mas"                                      |

      """
  Scenario: List languages
    When I run cucumber --i18n help
    Then STDERR should be empty
    Then it should pass with
      """
            | ar        | Arabic                 | العربية              |
            | bg        | Bulgarian              | български            |
            | ca        | Catalan                | català               |
            | cs        | Czech                  | Česky                |
            | cy-GB     | Welsh                  | Cymraeg              |
            | da        | Danish                 | dansk                |
            | de        | German                 | Deutsch              |
            | en        | English                | English              |
            | en-Scouse | Scouse                 | Scouse               |
            | en-au     | Australian             | Australian           |
            | en-lol    | LOLCAT                 | LOLCAT               |
            | en-pirate | Pirate                 | Pirate               |
            | en-tx     | Texan                  | Texan                |
            | eo        | Esperanto              | Esperanto            |
            | es        | Spanish                | español              |
            | et        | Estonian               | eesti keel           |
            | fi        | Finnish                | suomi                |
            | fr        | French                 | français             |
            | he        | Hebrew                 | עברית                |
            | hr        | Croatian               | hrvatski             |
            | hu        | Hungarian              | magyar               |
            | id        | Indonesian             | Bahasa Indonesia     |
            | it        | Italian                | italiano             |
            | ja        | Japanese               | 日本語                  |
            | ko        | Korean                 | 한국어                  |
            | lt        | Lithuanian             | lietuvių kalba       |
            | lu        | Luxemburgish           | Lëtzebuergesch       |
            | lv        | Latvian                | latviešu             |
            | nl        | Dutch                  | Nederlands           |
            | no        | Norwegian              | norsk                |
            | pl        | Polish                 | polski               |
            | pt        | Portuguese             | português            |
            | ro        | Romanian               | română               |
            | ro-RO     | Romanian (diacritical) | română (diacritical) |
            | ru        | Russian                | русский              |
            | sk        | Slovak                 | Slovensky            |
            | sr-Cyrl   | Serbian                | Српски               |
            | sr-Latn   | Serbian (Latin)        | Srpski (Latinica)    |
            | sv        | Swedish                | Svenska              |
            | tr        | Turkish                | Türkçe               |
            | uk        | Ukrainian              | Українська           |
            | uz        | Uzbek                  | Узбекча              |
            | vi        | Vietnamese             | Tiếng Việt           |
            | zh-CN     | Chinese simplified     | 简体中文                 |
            | zh-TW     | Chinese traditional    | 繁體中文                 |

      """
