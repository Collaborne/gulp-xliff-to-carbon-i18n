const expect = require('chai').expect;
const vinyl = require('vinyl');
const fs = require('fs');
const xliff2js = require('../index.js');

describe('gulp-xliff-to-carbon-i18n', function() {
	describe('XLIFF processing', function() {
		var samples;
		var locales;
		var Polymer;

		beforeEach(function() {
			samples = new vinyl({
				cwd: '/home/test/',
				base: '/home/test/test/',
				path: '/home/test/test/samples.xliff',
				contents: new Buffer(fs.readFileSync('test/samples.xliff'))
			});

			// Setup the fake carbon-i18n element so we can look at the processed content.
			locales = {};
			Polymer = {
				CarbonI18nBehaviorLocales: {
					add: function(element, lang, i18n) {
						locales[element] = {};
						locales[element][lang] = i18n;
					}
				}
			};
		});

		/**
		 * Process `file` and check expectations.
		 *
		 * @param {vinyl} file the Vinyl file to process
		 * @param {function} expectations callback, invoked with the `locales` parameter
		 */
		function process(file, expectations) {
			var stream = xliff2js.apply();
			stream.on('data', function(file) {
				var results = file.contents.toString();
				eval(results);
			});
			stream.on('end', function() {
				expectations(locales);
			});
			stream.write(file);
			stream.end();
		}

		it('should handle single quotes', function(done) {
			process(samples, function(locales) {
				expect(locales['samples']['en-test']['single_quotes']).to.be.equal('Foo\'Bar');
				done();
			});
		});
	});
});
