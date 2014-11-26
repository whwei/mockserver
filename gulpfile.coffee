gulp = require 'gulp'
mocha = require 'gulp-spawn-mocha'

gulp.task 'default', ['watch-test']


gulp.task 'test', ->
    gulp.src 'test/**/*.spec.coffee'
    .pipe(mocha {reporter: 'nyan'})

gulp.task 'watch-test', ->
    gulp.watch ['app/**/*.coffee', 'test/**/*.spec.coffee'], ['test']
