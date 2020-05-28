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
