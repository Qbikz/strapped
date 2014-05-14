/*global module:false*/
/*global require:false*/
/*global global:false*/
/*global process:false*/

module.exports = function(grunt) {
  'use strict';

  // Set global environment variable
  global['NODE_ENV'] = process.env.NODE_ENV || 'development';

  // Create default directories
  grunt.file.mkdir('public');
  grunt.file.mkdir('shared/media');
  grunt.file.mkdir('shared/tmp');
  grunt.file.mkdir('shared/logs');

  // Initialize config
  grunt.initConfig({
    pkg:          grunt.file.readJSON('package.json'),
    copy:         grunt.file.readJSON('etc/grunt/copy.json'),
    jshint:       grunt.file.readJSON('etc/grunt/jshint.json'),
    csslint:      grunt.file.readJSON('etc/grunt/csslint.json'),
    uglify:       grunt.file.readJSON('etc/grunt/uglify.json'),
    less:         grunt.file.readJSON('etc/grunt/less.json'),
    watch:        grunt.file.readJSON('etc/grunt/watch.json'),
    php:          grunt.file.readJSON('etc/grunt/php.json'),
    phpcs:        grunt.file.readJSON('etc/grunt/phpcs.json'),
    phplint:      grunt.file.readJSON('etc/grunt/phplint.json'),
    phpunit:      grunt.file.readJSON('etc/grunt/phpunit.json'),
    php_analyzer: grunt.file.readJSON('etc/grunt/phpanalyzer.json'),
    behat:        grunt.file.readJSON('etc/grunt/behat.json'),
    project:      grunt.file.readJSON('etc/grunt/project.json'),
    database:     grunt.file.readJSON('etc/grunt/database.json'),
    symlink:      grunt.file.readJSON('etc/grunt/symlink.json')
  });

  // Load contrib tasks
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-csslint');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-symlink');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-less');

  // Load PHP tasks
  grunt.loadNpmTasks('grunt-phpcs');
  grunt.loadNpmTasks('grunt-php');
  grunt.loadNpmTasks('grunt-phplint');
  grunt.loadNpmTasks('grunt-parallel-behat');
  grunt.loadNpmTasks('grunt-phpunit');
  grunt.loadNpmTasks('grunt-php-analyzer');

  // Load custom tasks
  require('./etc/grunt/tasks/composer')(grunt);
  require('./etc/grunt/tasks/database')(grunt);
  require('./etc/grunt/tasks/project')(grunt);

  // Create tasks composed out of other tasks
  grunt.registerTask('test', [
    'phplint:project',
    'php_analyzer:project',
    'phpcs:project',
    'csslint:project',
    'jshint:project',
    'phpunit:project',
    'behat'
  ]);
};
