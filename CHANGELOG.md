# Change Log

## [Unreleased](https://github.com/grtjn/mlvagrant/tree/HEAD)

[Full Changelog](https://github.com/grtjn/mlvagrant/compare/1.0.0...HEAD)

**Fixed bugs:**

- First time backup-cache fails [\#79](https://github.com/grtjn/mlvagrant/issues/79)

## [1.0.0](https://github.com/grtjn/mlvagrant/tree/1.0.0) (2015-09-08)
**Implemented enhancements:**

- Make bootstrap run on CentOS 5 [\#74](https://github.com/grtjn/mlvagrant/issues/74)
- Don't do full update, and dev tools by default [\#73](https://github.com/grtjn/mlvagrant/issues/73)
- Republish bento base boxes [\#71](https://github.com/grtjn/mlvagrant/issues/71)
- Chef boxes no longer available [\#67](https://github.com/grtjn/mlvagrant/issues/67)
- Make sure VAGRANT\_DOTFILE\_PATH is set correctly [\#63](https://github.com/grtjn/mlvagrant/issues/63)
- Allow public network as option [\#62](https://github.com/grtjn/mlvagrant/issues/62)
- Add dev tools installation [\#61](https://github.com/grtjn/mlvagrant/issues/61)
- Add examples of all settings to project.properties [\#60](https://github.com/grtjn/mlvagrant/issues/60)
- Suppress unnecessary NPM output [\#59](https://github.com/grtjn/mlvagrant/issues/59)
- Support for chef/centos7.0 [\#51](https://github.com/grtjn/mlvagrant/issues/51)
- Improve restart check [\#50](https://github.com/grtjn/mlvagrant/issues/50)
- Option to use internal network instead public for clusters [\#45](https://github.com/grtjn/mlvagrant/issues/45)
- Upgrade to ML 6.0-6 and 7.0-5.2 [\#44](https://github.com/grtjn/mlvagrant/issues/44)
- Update to support ML 7.0-5.1 and 8.0-3 [\#40](https://github.com/grtjn/mlvagrant/issues/40)
- Make installer names configurable [\#39](https://github.com/grtjn/mlvagrant/issues/39)
- Upgrade install to ML 7.0-5 and MLCP 1.2-4 [\#36](https://github.com/grtjn/mlvagrant/issues/36)
- Git post-receive hook needs to be improved [\#32](https://github.com/grtjn/mlvagrant/issues/32)
- Upgrade install to ML 8.0-2 and MLCP 1.3-2 [\#31](https://github.com/grtjn/mlvagrant/issues/31)
- Make VM names customizable [\#25](https://github.com/grtjn/mlvagrant/issues/25)
- Consider switching to private\_network as default [\#24](https://github.com/grtjn/mlvagrant/issues/24)
- Make mem and cpus easier to customize [\#23](https://github.com/grtjn/mlvagrant/issues/23)
- Make installation of things like tomcat optional [\#22](https://github.com/grtjn/mlvagrant/issues/22)
- Update ML and MLCP versions [\#20](https://github.com/grtjn/mlvagrant/issues/20)
- Allow running bootstrap scripts outside mlvagrant as well [\#17](https://github.com/grtjn/mlvagrant/issues/17)
- Support project-specific licences [\#16](https://github.com/grtjn/mlvagrant/issues/16)
- Support for command-line params and a project.properties [\#15](https://github.com/grtjn/mlvagrant/issues/15)
- Add latest version of ML8 EA and MLCP 1.3 EA [\#12](https://github.com/grtjn/mlvagrant/issues/12)
- Install tomcat [\#11](https://github.com/grtjn/mlvagrant/issues/11)
- setup-ml scripts only support v7+ [\#9](https://github.com/grtjn/mlvagrant/issues/9)
- Filename of rpm files are "hardcoded" in install-ml-CentOS.sh [\#8](https://github.com/grtjn/mlvagrant/issues/8)
- Automate replication of built-in databases [\#7](https://github.com/grtjn/mlvagrant/issues/7)
- Install latest ML versions [\#3](https://github.com/grtjn/mlvagrant/issues/3)
- Copy yum cache between VMs to speed up download [\#2](https://github.com/grtjn/mlvagrant/issues/2)

**Fixed bugs:**

- Yum cache multiplied at backup/restore to/from host [\#75](https://github.com/grtjn/mlvagrant/issues/75)
- Line-ends in .properties causing trouble on Windows [\#70](https://github.com/grtjn/mlvagrant/issues/70)
- Checking if box 'chef/centos-6.5' is up to date: 404 Not Found [\#68](https://github.com/grtjn/mlvagrant/issues/68)
- /vagrant/project.properties: no such file or directory [\#66](https://github.com/grtjn/mlvagrant/issues/66)
- dependency warnings on provision - cluster not configured [\#65](https://github.com/grtjn/mlvagrant/issues/65)
- cp: cannot stat `/space/software/yum' [\#64](https://github.com/grtjn/mlvagrant/issues/64)
- no implicit conversion of nil into String \(TypeError\) [\#57](https://github.com/grtjn/mlvagrant/issues/57)
- /usr/local/bin/vagrant: No such file or directory [\#56](https://github.com/grtjn/mlvagrant/issues/56)
- yum write permissions [\#55](https://github.com/grtjn/mlvagrant/issues/55)
- Tomcat error when running vagrant provision [\#54](https://github.com/grtjn/mlvagrant/issues/54)
- Make sure scripts still run stand-alone [\#52](https://github.com/grtjn/mlvagrant/issues/52)
- Make script names have consistent case [\#48](https://github.com/grtjn/mlvagrant/issues/48)
- Install tomcat error [\#47](https://github.com/grtjn/mlvagrant/issues/47)
- http://download-i2.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm is not valid anymore [\#43](https://github.com/grtjn/mlvagrant/issues/43)
- Gulp and Bower not installing [\#30](https://github.com/grtjn/mlvagrant/issues/30)
- Ignore network domain suffix in hostname [\#14](https://github.com/grtjn/mlvagrant/issues/14)
- Install java [\#10](https://github.com/grtjn/mlvagrant/issues/10)
- MLCP script wrong zip name [\#1](https://github.com/grtjn/mlvagrant/issues/1)

**Closed issues:**

- Document how to use bootstrap scripts outside Vagrant [\#72](https://github.com/grtjn/mlvagrant/issues/72)
- Document usage of hostmanager command [\#33](https://github.com/grtjn/mlvagrant/issues/33)
- Describe how to scale up and down [\#19](https://github.com/grtjn/mlvagrant/issues/19)
- Add latest features to docs [\#18](https://github.com/grtjn/mlvagrant/issues/18)
- Provide Windows-specific instructions [\#13](https://github.com/grtjn/mlvagrant/issues/13)
- Add a Contributing.md [\#6](https://github.com/grtjn/mlvagrant/issues/6)
- Document required license, and how to change [\#4](https://github.com/grtjn/mlvagrant/issues/4)

**Merged pull requests:**

- \#39 - Defined configurable properties for ML installer and MLCP insta… [\#49](https://github.com/grtjn/mlvagrant/pull/49) ([daveegrant](https://github.com/daveegrant))
- Added additional parameters to support synced folder and ip-adress [\#42](https://github.com/grtjn/mlvagrant/pull/42) ([mstellwa](https://github.com/mstellwa))
- PR for Issue \#40 - Adding Support for ML 8.0-3 and MLCP 1.3-3 [\#41](https://github.com/grtjn/mlvagrant/pull/41) ([daveegrant](https://github.com/daveegrant))
- Updates to use latest version of ML 7 and MLCP. [\#37](https://github.com/grtjn/mlvagrant/pull/37) ([daveegrant](https://github.com/daveegrant))
- Upgrade to MarkLogic 8.0-2 [\#35](https://github.com/grtjn/mlvagrant/pull/35) ([patrickmcelwee](https://github.com/patrickmcelwee))
- Fixes for \#30 and \#13 [\#34](https://github.com/grtjn/mlvagrant/pull/34) ([daveegrant](https://github.com/daveegrant))
- Fixed case sensitivy problem with provision script [\#27](https://github.com/grtjn/mlvagrant/pull/27) ([vladistan](https://github.com/vladistan))
- Fixed up handling of project.properties file [\#26](https://github.com/grtjn/mlvagrant/pull/26) ([vladistan](https://github.com/vladistan))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*