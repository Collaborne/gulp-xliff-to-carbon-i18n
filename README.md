gulp-xliff-to-carbon-i18n [![Build Status](https://travis-ci.org/Collaborne/gulp-xliff-to-carbon-i18n.svg?branch=master)](https://travis-ci.org/Collaborne/gulp-xliff-to-carbon-i18n)
=========
Plugin for gulp to convert XLIFF 1.2 files into JS files for use with [Collaborne/carbon-i18n-behavior](https://github.com/Collaborne/carbon-i18n-behavior)

_[Blog post explaining the plugin](https://medium.com/collaborne-engineering/localize-polymer-applications-with-a-translation-agency-b3291b574c85)_

## Installation

	$ npm install --save-dev gulp-xliff-to-carbon-i18n

## Usage

```js
var xliff2js = require('gulp-xliff-to-carbon-i18n');

gulp.task('process-xliff-files', function() {
    gulp.src('**/*.xliff')
        .pipe(xliff2js())
        .pipe(gulp.dest('dist'));
});
```

### Options

`useSource`: If set to `true` then the plugin produces output for the *source* language, otherwise for the *target* language.

## License

    This software is licensed under the Apache 2 license, quoted below.

    Copyright 2011-2015 Collaborne B.V. <http://github.com/Collaborne/>

    Licensed under the Apache License, Version 2.0 (the "License"); you may not
    use this file except in compliance with the License. You may obtain a copy of
    the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
    License for the specific language governing permissions and limitations under
    the License.
