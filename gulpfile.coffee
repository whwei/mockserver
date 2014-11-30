gulp = require 'gulp'
mocha = require 'gulp-spawn-mocha'
coffee = require 'gulp-coffee'

gulp.task 'default', ['watch-test']


gulp.task 'build', ->


gulp.task 'compile-coffee', ->
    gulp.src 'app/**/*.coffee'
    .pipe coffee({bare: true})
    .on 'error', (err) ->
        console.log err
    .pipe gulp.dest('build/')

gulp.task 'test', ->
    gulp.src 'test/**/*.spec.coffee'
    .pipe(mocha {reporter: 'nyan'})

gulp.task 'watch-test', ->
    gulp.watch ['app/**/*.coffee', 'test/**/*.spec.coffee'], ['test']
