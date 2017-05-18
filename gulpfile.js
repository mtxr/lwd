const gulp = require('gulp')
const ts = require('gulp-typescript')
const tsProject = ts.createProject('tsconfig.json')

gulp.task('compile', () => {
  return tsProject.src()
    .pipe(tsProject())
    .js.pipe(gulp.dest('bin'))
})

gulp.task('watch', () => {
  return gulp.watch('./src/**/*.ts', ['default'])
})

gulp.task('default', ['compile'])
