# Strapped
Your #1 toolkit to ease development and bootstrap your project. Based on Vagrant, Grunt and Composer, it ensures a proper workflow and easy deployment.

## Tools
- Vagrant
- Grunt
- Composer

# First time setup
On Debian based systems run `sudo bin/install.sh`. This will install all local
dependencies such as:
- Curl
- Git / Git Flow
- Virtualbox
- Vagrant
- NFS Server
- PHP-CLI
- MySQL Client
- NodeJS / NPM
- Grunt CLI

On other platforms make sure you have at least a NFS server, Vagrant and Virtualbox installed.

# Bootstrap your project
If you just checked out this project, run `vagrant up` in the project root to create the virtual instance. This will create a new virtual Vagrant machine with the installed project

# Update your project
Run the command `grunt project:update` to update your project. This will update all composer resources, and applies upgrade scripts in the shell.

# Test your project
Run the command `grunt project:test` to perform PHP checks. This will perform the following routines:
- PHPlint
- CSSlint
- JSlint
- PHP Analyzer
- PHP CodeSniffer
- Pdepend
- PHP Unit
- Behat + Mink

# Development Tools
The toolkit offers some development tools to ease working with remote resources or tools.

## Database Management

* db:drop --target=environment
* db:create --target=environment
* db:restore --target=environment --source=environment
* db:backup --target=environment

## Synchronization and Building
Using `grunt watch` will trigger watch events on your projects files. If such an event occurs the correspondig tasks will be executed. With this tool your LESS files will be compiled, JavaScript files concatenated and/or compressed, project files copied to the public folder and more. Try it now!

# Working directories

* `private/files`
  Keep your project specific files in this place. It overwrites all files already compiled into 'public'
* `private/tests`
  Place PHPunit and Behat test cases in here
* `private/features`
  Place Behat features in this folder
* `private/themes`
  Main themes folder

# Compiled state

All files will be compiled into the `public` folder.
