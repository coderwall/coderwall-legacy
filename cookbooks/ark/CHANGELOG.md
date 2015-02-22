ark Cookbook CHANGELOG
======================
This file is used to list changes made in each version of the ark cookbook.


v0.9.0 (2014-06-06)
-------------------
* [COOK-3642] Add Windows support


v0.8.2 (2014-04-23)
-------------------
- [COOK-4514] - Support for SLES with the Ark cookbook


v0.8.0 (2014-04-10)
-------------------
- [COOK-2771] - Add support for XZ compression


v0.7.2 (2014-03-28)
-------------------
- [COOK-4477] - Fix failing test suite
- [COOK-4484] - Replace strip_leading_dir attribute with more general strip_components


v0.7.0 (2014-03-18)
-------------------
- [COOK-4437] - configure and install_with_make should chown after unpack


v0.6.0 (2014-02-27)
-------------------
[COOK-3786] - Unable to install multiple versions of archive without duplication


v0.5.0 (2014-02-21)
-------------------
### Bug
- **[COOK-4288](https://tickets.opscode.com/browse/COOK-4288)** - Cleanup the Kitchen

### Improvement
- **[COOK-4264](https://tickets.opscode.com/browse/COOK-4264)** - Add node['ark']['package_dependencies'] to allow tuning packages.


v0.4.2
------
### Improvement
- **[COOK-3854](https://tickets.opscode.com/browse/COOK-3854)** - Capability with mac_os_x: '/bin/chown' - No such file or directory
- Cleaning up some style for rubucop
- Updating test harness


v0.4.0
------
### Improvement
- **[COOK-3539](https://tickets.opscode.com/browse/COOK-3539)** - Allow dumping of bz2 and gzip files

v0.3.2
------
### Bug
- **[COOK-3191](https://tickets.opscode.com/browse/COOK-3191)** - Propogate unzip failures
- **[COOK-3118](https://tickets.opscode.com/browse/COOK-3118)** - Set cookbook attribute in provider
- **[COOK-3055](https://tickets.opscode.com/browse/COOK-3055)** - Use proper scope in helper module
- **[COOK-3054](https://tickets.opscode.com/browse/COOK-3054)** - Fix notification resource updating

### Improvement
- **[COOK-3179](https://tickets.opscode.com/browse/COOK-3179)** - README updates and refactor

v0.3.0
------
### Improvement

- [COOK-3087]: Can't use ark with chef < 11

### Bug

- [COOK-3064]: `only_if` statements in ark's `install_with_make` and configure actions are not testing for file existence correctly.
- [COOK-3067]: ark kitchen test for `cherry_pick` is expecting the binary to be in the same parent folder as in the archive.

v0.2.4
------
### Bug

- [COOK-3048]: Ark provider contains a `ruby_block` resource without a block attribute
- [COOK-3063]: Ark cookbook `cherry_pick` action's unzip command does not close if statement
- [COOK-3065]: Ark install action does not symlink binaries correctly

v0.2.2
------
- Update the README to reflect the requirement for Chef 11 to use the ark resource (`use_inline_resources`).
- Making this a release so it will also appear on the community site page.

v0.2.0
------
### Bug

- [COOK-2772]: Ark cookbook has foodcritic failures in provides/default.rb

### Improvement

- [COOK-2520]: Refactor ark providers to use the '`use_inline_resources`' LWRP DSL feature

v0.1.0
------
- [COOK-2335] - ark resource broken on Chef 11

v0.0.1
------
- [COOK-2026] - Allow `cherry_pick` action to be used for directories as well as files

v0.0.1
------
- [COOK-1593] - README formatting updates for better display on Community Site

v0.0.1
------
### Bug
- dangling "unless"

### Improvement
- add `setup_py_*` actions
- add vagrantfile
- add foodcritic test
- travis.ci support

v0.0.10 (May 23, 2012
------
### Bug
- `strip_leading_dir` not working for zip files https://github.com/bryanwb/chef-ark/issues/19

### Improvement
- use autogen.sh to generate configure script for configure action https://github.com/bryanwb/chef-ark/issues/16
- support more file extensions https://github.com/bryanwb/chef-ark/pull/18
- add extension attribute which allows you to download files which do not have the file extension as part of the URL
