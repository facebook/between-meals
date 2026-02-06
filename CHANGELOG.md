# Changelog

## 0.0.13
* Provide IP address string to TCPSocket instead of Addrinfo
* Fix incorrect use of stdout
* Fix possible NilClass#sub
* Use fully-qualified class names
* Add annotations for steep
* Ignore UnexpectedYield
* Fix crash in databag upload (remove log messages before parsing JSON)
* Remove verbosity options from data bag list shellout
* Have repo auto-detection lazily load repository libraries
* Fix change detection for databags
* De-couple BetweenMeals::Repo class conformance tests

## 0.0.12
* Moved to Actions, deprecated Travis+Circle
* Unified style to match other FB-Chef-related-repos
* Linted Markdown docs
* Provide access to underlying repo object, if one exists
* git: Don't assume 'git-svn'
* git: Better handling of `git config` when a field is not set
* Cleanup gemspec
* Drop ruby 2.3 support

## 0.0.11
* Eliminate mkdir race condition
* Handle spaces in filenames
* Expose Mixlib::ShellOut's streaming in Utils
* Make knife verbose if logging level is DEBUG or INFO

## 0.0.10
* Ensure errors are logged to the logger
* Fix logging when `hg pull` fails
* Fix symlink handling

## 0.0.9
* New helpers for testing if chef-zero is running more methodically
* Ensure _all_addresses when determining of a port is open
* Gracefully handle cookbooks with both `metadata.json` and `metadata.rb`
* Fix amend on hg so it only modifies the message, not the code
* Remove the dependency on JSON now that 2.4 has it

## 0.0.8
* Create pem dir if it does not exist
* Add option to track symlinks
* Handle metadata.json in addition to metadata.rb
* Make cookbook dirs accessible from outside the knife object
* Update path for MacOSX

## 0.0.7
* Cleaned up error messages
* Add support for JSON roles

## 0.0.6
* Mercurial support
* Support for auto-detecting repo type
* Fix uploading of all roles
* Support for using berkshelf for cookbooks
* Several bugfixes for SVN diff parsing

## 0.0.5
* When deleting a cookbook, delete all versions
* Delete all versions of a cookb
* Support SSL/HTTPS scheme for knife config
