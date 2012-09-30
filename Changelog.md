# 0.0.1.0pre

## New configuration system! 

Copy over config/diaspora.yml.example to config/diaspora.yml and migrate your settings! An updated Heroku guide including basic hints on howto migrate is [here](https://github.com/diaspora/diaspora/wiki/Installing-on-heroku).

The new configuration system allows all possible settings to be overriden by environment variables. This makes it possible to deploy heroku without checking any credentials into git. Read the top of `config/diaspora.yml.example` for an explanation on how to convert the setting names to environment variables.

### Environment variable changes:

#### deprectated

* REDISTOGO_URL in favour of REDIS_URL or ENVIRONMENT_REDIS

#### removed

*  application_yml - Obsolete, all settings are settable via environment variables now

#### renamed

* SINGLE_PROCESS_MODE -> ENVIRONMENT_SINGLE_PROCESS_MODE
* SINGLE_PROCESS -> ENVIRONMENT_SINGLE_PROCESS_MODE
* NO_SSL -> ENVIRONMENT_REQUIRE_SSL
* ASSET_HOST -> ENVIRONMENT_ASSETS_HOST