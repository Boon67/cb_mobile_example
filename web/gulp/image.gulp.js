const gulp = require('gulp');
const del = require('del');

const {
  dependencies,
  images,
  baseDir,
  isIterableArray,
} = require('./utils.js');

/*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
|  Vendor
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*/
// Move image image files from  to public images folder
gulp.task('image:move', () => {
    return gulp.src([
      'src/img/favicons/**/*',
      'src/img/gallery/**/*',
      'src/img/icons/**/*'
  ],  {base: 'src/'}) 
  .pipe(gulp.dest('./public/assets'))

});

gulp.task('image:clean', () => {
    return del([
      'public/img/**/*.png',
    ]);
  });

gulp.task('image', gulp.series('image:clean', 'image:move'));
