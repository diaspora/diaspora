# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gem_plugin}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Zed A. Shaw"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDUDCCAjigAwIBAgIBADANBgkqhkiG9w0BAQUFADBOMRwwGgYDVQQDDBNtb25n\ncmVsLWRldmVsb3BtZW50MRkwFwYKCZImiZPyLGQBGRYJcnVieWZvcmdlMRMwEQYK\nCZImiZPyLGQBGRYDb3JnMB4XDTA3MDkxNjEwMzI0OVoXDTA4MDkxNTEwMzI0OVow\nTjEcMBoGA1UEAwwTbW9uZ3JlbC1kZXZlbG9wbWVudDEZMBcGCgmSJomT8ixkARkW\nCXJ1Ynlmb3JnZTETMBEGCgmSJomT8ixkARkWA29yZzCCASIwDQYJKoZIhvcNAQEB\nBQADggEPADCCAQoCggEBAMb9v3B01eOHk3FyypbQgKXzJplUE5P6dXoG+xpPm0Lv\nP7BQmeMncOwqQ7zXpVQU+lTpXtQFTsOE3vL7KnhQFJKGvUAkbh24VFyopu1I0yqF\nmGu4nRqNXGXVj8TvLSj4S1WpSRLAa0acLPNyKhGmoV9+crqQypSjM6XKjBeppifo\n4eBmWGjiJEYMIJBvJZPJ4rAVDDA8C6CM1m3gMBGNh8ELDhU8HI9AP3dMIkTI2Wx9\n9xkJwHdroAaS0IFFtYChrwee4FbCF1FHDgoTosMwa47DrLHg4hZ6ojaKwK5QVWEV\nXGb6ju5UqpktnSWF2W+Lvl/K0tI42OH2CAhebT1gEVUCAwEAAaM5MDcwCQYDVR0T\nBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0OBBYEFGHChyMSZ16u9WOzKhgJSQ9lqDc5\nMA0GCSqGSIb3DQEBBQUAA4IBAQA/lfeN2WdB1xN+82tT7vNS4HOjRQw6MUh5yktu\nGQjaGqm0UB+aX0Z9y0B0qpfv9rj7nmIvEGiwBmDepNWYCGuW15JyqpN7QVVnG2xS\nMrame7VqgjM7A+VGDD5In5LtWbM/CHAATvvFlQ5Ph13YE1EdnVbZ65c+KQv+5sFY\nQ+zEop74d878uaC/SAHHXS46TiXneocaLSYw1CEZs/MAIy+9c4Q5ESbGpgnfg1Ad\n6lwl7k3hsNHO/+tZzx4HJtOXDI1yAl3+q6T9J0yI3z97EinwvAKhS1eyOI2Y5eeT\ntbQaNYkU127B3l/VNpd8fQm3Jkl/PqCCmDBQjUszFrJEODug\n-----END CERTIFICATE-----\n", "-----BEGIN CERTIFICATE-----\nMIIDPzCCAiegAwIBAgIBADANBgkqhkiG9w0BAQUFADBOMRwwGgYDVQQDDBNtb25n\ncmVsLWRldmVsb3BtZW50MRkwFwYKCZImiZPyLGQBGRYJcnVieWZvcmdlMRMwEQYK\nCZImiZPyLGQBGRYDb3JnMB4XDTA3MDkxNjEwMzMwMFoXDTA4MDkxNTEwMzMwMFow\nPTENMAsGA1UEAwwEZXZhbjEYMBYGCgmSJomT8ixkARkWCGNsb3VkYnVyMRIwEAYK\nCZImiZPyLGQBGRYCc3QwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDk\nLQijz2fICmev4+9s0WB71WzJFYCUYFQQxqGlenbxWut9dlPSsBbskGjg+UITeOXi\ncTh3MTqAB0i1LJyNOiyvDsAivn7GjKXhVvflp2/npMhBBe83P4HOWqeQBjkk3QJI\nFFNBvqbFLeEXIP+HiqAOiyNHZEVXMepLEJLzGrg3Ly7M7A6L5fK7jDrt8jkm+c+8\nzGquVHV5ohAebGd/vpHMLjpA7lCG5+MBgYZd33rRfNtCxDJMNRgnOu9PsB05+LJn\nMpDKQq3x0SkOf5A+MVOcadNCaAkFflYk3SUcXaXWxu/eCHgqfW1m76RNSp5djpKE\nCgNPK9lGIWpB3CHzDaVNAgMBAAGjOTA3MAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSw\nMB0GA1UdDgQWBBT5aonPfFBdJ5rWFG+8dZwgyB54LjANBgkqhkiG9w0BAQUFAAOC\nAQEAiKbzWgMcvZs/TPwJxr8tJ+7mSGz7+zDkWcbBl8FpQq1DtRcATh1oyTkQT7t+\nrFEBYMmb0FxbbUnojQp8hIFgFkUwFpStwWBL/okLSehntzI2iwjuEtfj4ac9Q3Y2\nuSdbmZqsQTuu+lEUc5C4qLK7YKwToaul+cx7vWxyk1YendcVwRlFLIBqA5cPrwo3\nyyGLTHlRYn2c9PSbM1B63Yg+LqSSAa4QSU3Wv9pNdffVpvwHPVEQpO7ZDo5slQFL\nGf6+gbD/eZAvhpvmn8JlXb+LxKaFVMs2Yvrk1xOuT76SsPjEGWxkr7jZCIpsYfgQ\nALN3mi/9z0Mf1YroliUgF0v5Yw==\n-----END CERTIFICATE-----\n"]
  s.date = %q{2007-10-26}
  s.default_executable = %q{gpgen}
  s.description = %q{A plugin system based on rubygems that uses dependencies only}
  s.email = %q{}
  s.executables = ["gpgen"]
  s.files = ["test/test_plugins.rb", "setup.rb", "resources/resources/defaults.yaml", "resources/README", "resources/Rakefile", "resources/LICENSE", "resources/lib/project/init.rb", "resources/COPYING", "README", "Manifest", "LICENSE", "lib/gem_plugin.rb", "COPYING", "CHANGELOG", "bin/gpgen", "gem_plugin.gemspec"]
  s.homepage = %q{}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mongrel}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A plugin system based on rubygems that uses dependencies only}
  s.test_files = ["test/test_plugins.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
