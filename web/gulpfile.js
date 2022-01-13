const gulp = require('gulp');
const requireDir = require('require-dir');

requireDir('./gulp');

/*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
|  Compile
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*/
gulp.task('compile', gulp.parallel('style', 'script', 'image', 'script:webpack', 'vendor'));
gulp.task('compile:all', gulp.parallel('compile', 'pug'));

/*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
|  Deploy
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*/
gulp.task('build', gulp.series('clean:build', 'build:static', 'compile:all'));
gulp.task('build:test', gulp.series('build', 'watch'));

/*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
|  Run development environment
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*/
gulp.task('default', gulp.series('clean', 'compile', 'watch'));
