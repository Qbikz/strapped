
/**
 * [exports description]
 * @param  {[type]} grunt [description]
 * @return {[type]}       [description]
 */

module.exports = function(grunt) {
  'use strict';

  var _         = require('lodash');
  var shell     = require('shelljs')
  var config    = getConfig(grunt.config.get('project'), NODE_ENV);
  var database  = getConfig(grunt.config.get('database'), NODE_ENV);

  /**
   * [getConfig description]
   *
   * @param  {Object}   _config     [description]
   * @param  {String}   environment [description]
   * @return {Object}               [description]
   */
  function getConfig(_config, environment) {
    if (typeof(_config['default']) === 'undefined') {
      if (typeof(_config[environment]) === 'undefined') {
        return {};
      }
      return _config[environment];
    }
    return _.defaults(_config[environment], _config['default']);
  }

  /**
   * Download Project and put it into the repository
   *
   * @return {[type]} [description]
   */
  grunt.registerTask('project:clean', 'Clean Project', function() {
    grunt.log.writeln('Clearing "public" directory.');
    grunt.file.delete('public');
    grunt.file.mkdir('public');
  });

  /**
   * Deploy the project in the current environment
   *
   * @return {[type]} [description]
   */
  grunt.registerTask('project:install', [
    'db:create',
    'project:clean',
    'composer:install',
    'symlink',
    'copy:private',
    'project:install:magento',
    'project:config:generate'
  ]);

  /**
   * Deploy the project in the current environment
   *
   * @return {[type]} [description]
   */
  grunt.registerTask('project:reinstall:full', [
    'db:drop',
    'db:create',
    'project:clean',
    'composer:install',
    'symlink',
    'copy:private',
    'project:install:magento',
    'project:config:generate'
  ]);

  /**
   * Deploy the project in the current environment
   *
   * @return {[type]} [description]
   */
  grunt.registerTask('project:reinstall', [
    'copy:private',
    'db:drop',
    'db:create',
    'project:config:remove',
    'project:install:magento',
    'project:config:generate'
  ]);

  /**
   * Install the project
   */
  grunt.registerTask('project:install:magento', 'Install Magento Project', function() {
    if(grunt.file.exists('public/app/etc/local.xml')) {
      grunt.log.error('Magento is already installed. Terminating.')
      return;
    }

    var cmd =
      '/usr/bin/env php -f ./public/install.php -- ' +
      '--license_agreement_accepted "yes" ' +
      '--locale "<%= config.settings_locale %>" ' +
      '--timezone "<%= config.settings_timezone %>" ' +
      '--default_currency "<%= config.settings_currency %>" ' +
      '--session_save "<%= config.settings_session %>" ' +
      '--db_host "<%= db.host %>" ' +
      '--db_name "<%= db.name %>" ' +
      '--db_user "<%= db.user %>" ' +
      '--db_pass "<%= db.pass %>" ' +
      '--db_prefix "<%= db.prefix %>" ' +
      '--url "<%= config.url_unsecure %>" ' +
      '--secure_base_url "<%= config.url_secure %>" ' +
      '--use_rewrites "yes" ' +
      '--use_secure "no" ' +
      '--use_secure_admin "no" ' +
      '--skip_url_validation ' +
      '--enable_charts "yes" ' +
      '--admin_frontname "<%= config.admin_route %>" ' +
      '--admin_firstname "<%= config.admin_firstname %>" ' +
      '--admin_lastname "<%= config.admin_lastname %>" ' +
      '--admin_email "<%= config.admin_email %>" ' +
      '--admin_username "<%= config.admin_username %>" ' +
      '--admin_password "<%= config.admin_password %>" ' +
      '--encryption_key "<%= config.encryption_key %>"';

    cmd = grunt.template.process(cmd, {
      data: {
        config: config,
        db: database
      }
    });

    shell.exec(cmd);
    grunt.log.oklns('Succesfully installed Magento');
  });

  /**
   * Install the project
   */
  grunt.registerTask('project:config:generate', 'Install Magento Project', function() {
    if(grunt.file.exists('./templates/local.xml')) {
      grunt.log.error('Template file does not exist.')
      return;
    }

    var localXml = grunt.template.process(grunt.file.read('./etc/grunt/tasks/templates/local.xml'), {
      data: {
        config: config,
        db: database
      }
    });

    grunt.file.delete('./public/app/etc/local.xml');
    grunt.file.delete('./public/var/cache');
    grunt.file.write('./public/app/etc/local.xml', localXml);
    grunt.log.oklns('Succesfully configured Magento');
  });

  /**
   * Install the project
   */
  grunt.registerTask('project:config:remove', 'Install Magento Project', function() {
    if(! grunt.file.exists('./public/app/etc/local.xml')) {
      grunt.log.error('Local.xml does not exist.')
      return;
    }

    grunt.file.delete('./public/app/etc/local.xml');
    grunt.log.oklns('Succesfully removed local.xml');
  });
};
