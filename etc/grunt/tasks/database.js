
/**
 * [exports description]
 * @param  {[type]} grunt [description]
 * @return {[type]}       [description]
 */

module.exports = function(grunt) {
  'use strict';

  var shell = require('shelljs'),
      config = grunt.config.get('database');

  /**
   * Create Database
   * 
   * @TODO: Catch errors
   */
  grunt.registerTask('db:create', 'Create Database', function() {
    var target = grunt.option('target');

    if (typeof target === 'undefined') {
      target = NODE_ENV;
    }

    if (typeof config[target] === 'undefined') {
      grunt.fail.warn('Invalid target provided.', 6);
    }

    var create = grunt.template.process(tpls.create, { data: config[target] });

    if (target === NODE_ENV || config[target].ssh === 'undefined') {
      shell.exec(create, {silent: true});
    } else {
      var ssh = grunt.template.process(tpls.ssh, { data: config[target] });
      shell.exec(ssh + ' \\ ' + create, {silent: true});
    }

    grunt.log.oklns('Created database succesfully on target: ' + target);
  });

  /**
   * Drops Database
   */
  grunt.registerTask('db:drop', 'Drop Database', function() {
    var target = grunt.option('target');

    if (typeof target === 'undefined') {
      target = NODE_ENV;
    }

    if (typeof config[target] === 'undefined') {
      grunt.fail.warn('Invalid target provided.', 6);
    }

    var drop = grunt.template.process(tpls.drop, { data: config[target] });

    if (target === NODE_ENV || config[target].ssh === 'undefined') {
      shell.exec(drop, {silent: true});
    } else {
      var ssh = grunt.template.process(tpls.ssh, { data: config[target] });
      shell.exec(ssh + ' \\ ' + drop, {silent: true});
    }

    grunt.log.oklns('Dropped succesfully on target: ' + target);
  });

  /**
   * Backup Database
   */
  grunt.registerTask('db:backup', 'Backup Database', function() {
    var target = grunt.option('target');

    if (! shell.which('mysqldump')) {
      grunt.fail.warn('Sorry, this script requires the mysqldump binary');
    }

    if (typeof target === 'undefined') {
      target = NODE_ENV;
    }

    if (typeof config[target] === 'undefined') {
      grunt.fail.warn('Invalid target provided.', 6);
    }

    grunt.log.writeln('Backing up ' + config[target].title + ' database');

    var file = grunt.template.process(tpls.filename, {
      data: {
        env: target,
        date: grunt.template.today('yyyymmdd'),
        time: grunt.template.today('HH-MM-ss'),
      }
    });

    var dump = grunt.template.process(tpls.backup, {
      data: config[target]
    });

    if (target === NODE_ENV || config[target].ssh === 'undefined') {
      var ret = shell.exec(dump, { silent: true });
    } else {
      var ssh = grunt.template.process(tpls.ssh, {
        data: config[target]
      });
      var ret = shell.exec(ssh + ' \\ ' + dump, { silent: true });
    }

    grunt.file.mkdir('system/backups');
    grunt.file.write(file, ret.output);
    grunt.log.oklns('Database DUMP succesfully exported to: ' + file + '.gz');
  });

  /**
   * Restore Database
   */
  grunt.registerTask('db:restore', 'Restore Database', function() {
    var source  = grunt.option('source'),
        target  = grunt.option('target'),
        version = grunt.option('version');

    if (typeof target === 'undefined') {
      target = NODE_ENV;
    }

    if (typeof config[target] === 'undefined') {
      grunt.fail.warn('Invalid target provided.', 6);
    }
    
    if (typeof source === 'undefined') {
      source = target;
    } else if (typeof config[source] === 'undefined') {
      grunt.fail.warn('Invalid source provided.', 6);
    }

    var restore = grunt.template.process(tpls.restore, { data: config[target] });
  });

  /**
   * Lo-Dash Template Helpers
   * http://lodash.com/docs/#template
   * https://github.com/gruntjs/grunt/wiki/grunt.template
   */
  var tpls = {
    filename: 'system/backups/<%= env %>-<%= date %>-<%= time %>.sql.tgz',
    backup: 'mysqldump -u <%= user %> -p<%= pass %> <%= name %> | gzip',
    restore: 'gunzip < <%= file %> | mysql -h <%= host %> -u <%= user %> -p<%= pass %> <%= name %>',
    ssh: 'ssh <%= host %>',
    drop: 'mysql -h <%= host %> -u <%= user %> -p<%= pass %> -e "DROP DATABASE <%= name %>"',
    create: 'mysql -h <%= host %> -u <%= user %> -p<%= pass %> -e "CREATE DATABASE <%= name %>"',
  };
};
