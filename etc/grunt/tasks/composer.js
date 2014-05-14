
/**
 * Simple method to bypass any given method to Composer.
 *
 * @param   {Object}  The Grunt CLI object.
 * @return  {Void}    Returns nothing, just initiates.
 */

module.exports = function(grunt) {
  'use strict';

  var spawn = require('child_process').spawn;

  /**
   * [execCmd description]
   *
   * @param  {String}   cmd
   * @param  {Object}   args
   * @param  {Function} cb
   * @return {Void}
   */
  function execCmd(cmd, args, cb) {
    var exec = spawn(cmd, args);
    exec.stdout.on('data', grunt.log.write);
    exec.stderr.on('data', grunt.log.error);
    exec.on('close', function(code) {
      if(code == 127) {
        grunt.warn('Composer must be installed globally.  ' +
          "for more info, see:  https://getcomposer.org/doc/00-intro.md#globally.");
      }
      cb();
    });
  }

  /**
   * [description]
   * @param  {[type]} cmd
   * @param  {[type]} args
   * @return {[type]}
   */
  grunt.registerTask('composer', 'Composer for PHP', function(cmd, args) {
    if (! grunt.file.exists('bin/composer.phar')) {
      grunt.log.warn('Composer.phar not found. Please try again.');
    }
    var done = this.async();
    var cmdArgs = [cmd];
    for (arg in args) {
      cmdArgs.push('--' + arg);
    }
    cmdArgs.push('--working-dir')
    cmdArgs.push(process.cwd() + '/etc/composer');
    execCmd(process.cwd() + '/bin/composer.phar', cmdArgs, done);
  });

};
