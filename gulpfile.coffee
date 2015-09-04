gulp = require 'gulp'
coffee = require 'gulp-coffee'
plumber = require 'gulp-plumber'

gulp.task 'coffee', ->
	gulp.src './src/**/*.coffee'
		.pipe plumber()
		.pipe coffee({bare: true})
		.pipe gulp.dest './lib/'

gulp.task 'watch', ->
	gulp.watch './src/**/*.coffee', ['coffee']

gulp.task 'default', ['coffee']
