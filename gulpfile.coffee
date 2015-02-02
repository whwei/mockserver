gulp = require 'gulp'
mocha = require 'gulp-spawn-mocha'
coffee = require 'gulp-coffee'

gulp.task 'default', ['watch-test']


gulp.task 'build', ['compile-coffee']


gulp.task 'compile-coffee', ->
    gulp.src 'src/**/*.coffee'
    .pipe coffee({bare: true})
    .on 'error', (err) ->
        console.log err
    .pipe gulp.dest('build/')

gulp.task 'watch', ->
    gulp.watch 'src/**/*.coffee', ['compile-coffee']

gulp.task 'test', ->
    gulp.src 'test/**/*.spec.coffee'
    .pipe(mocha {reporter: 'nyan'})

gulp.task 'watch-test', ->
    gulp.watch ['src/**/*.coffee', 'test/**/*.spec.coffee'], ['test']
