## Welcome to the Diaspora Project!

Diaspora is a privacy-aware, personally-controlled, do-it-all open source social network. Check out our [project site](http://diasporaproject.org).

[![Build Status](https://secure.travis-ci.org/diaspora/diaspora.png)](http://travis-ci.org/diaspora/diaspora)
[![Dependency Status](https://gemnasium.com/diaspora/diaspora.png?travis)](https://gemnasium.com/diaspora/diaspora)

************************
Diaspora is currently going through a huge refactoring push, the code is changing fast!
If you want to do something big, reach out on IRC or the mailing list first, so you can contribute effectively <3333
************************

With Diaspora you can:

- Run and host your own pod and have control over your own social experience.
- Own your own data.
- Make friends across other pods seamlessly.

Documentation is available on our [wiki](https://github.com/diaspora/diaspora/wiki)

## Quick Start:

Here's how you can get a development environment up and running. You can check out system-specific guides [here](https://github.com/diaspora/diaspora/wiki/Installation-Guides).

### Step 1: Clone the repo 
```git clone git@github.com:diaspora/diaspora.git
```

### Step 2: Navigate to your cloned repository
```cd ../diaspora
```

### Step 3: Install Bundler and gems (depending on [OS Vendor](https://github.com/diaspora/diaspora/wiki/Installation-Guides))
```sudo gem install bundler && sudo bundle install
```

### Step 4: Edit database.yml, and rename application.yml.example to just application.yml 

### Step 5: Create and migrate the database
```rake db:create && rake db:migrate
```

### Step 6: Start the test server
```rails s
```

## Resources:

- [Wiki](https://github.com/diaspora/diaspora/wiki)
- [Podmin Resources](https://github.com/diaspora/diaspora/wiki/Podmin-Resources)
- [Contributing](https://github.com/diaspora/diaspora/wiki/Getting-Started-With-Contributing)
- [Dev List](https://groups.google.com/forum/?fromgroups#!forum/diaspora-dev)
- [Discuss List](https://groups.google.com/forum/?fromgroups#!forum/diaspora-discuss)
- [IRC](http://webchat.freenode.net?channels=diaspora-dev)