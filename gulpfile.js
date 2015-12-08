var gulp = require('gulp');
var babel = require('gulp-babel');

gulp.task('build', function() {
    return gulp.src('app/assets/src/js/*.js')
        .pipe(babel({ presets: ['es2015'] }))
        .pipe(gulp.dest('app/assets/javascripts'));
});

gulp.task('watch', function() {
    gulp.watch('app/assets/src/js/*.js', ['build']);
});

gulp.task('default', ['build']);
