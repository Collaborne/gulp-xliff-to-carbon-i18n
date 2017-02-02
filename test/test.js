'use strict';

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
		 * @param {Object} opts plugin options
		 * @param {vinyl} file the Vinyl file to process
		 * @param {function} expectations callback, invoked with the `locales` parameter
		 */
		function executePlugin(opts, file, expectations) {
			var stream = xliff2js.call(xliff2js, opts);
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
			executePlugin({ useSource: true }, samples, function(locales) {
				expect(locales['samples']['en']['single_quotes']).to.be.equal('Foo\'Bar');
				done();
			});
		});

		it('should handle embedded newlines', function(done) {
			executePlugin({ useSource: true }, samples, function(locales) {
				expect(locales['samples']['en']['newlines']).to.be.equal('Foo\nBar');
				done();
			});
		});

		it('should honor xml:space="preserve"', function(done) {
			executePlugin({ useSource: true }, samples, function(locales) {
				expect(locales['samples']['en']['xml_space_preserve']).to.match(/\s+non-translatable\s+/);
				done();
			});
		});

		it('should honor xml:space="default"', function(done) {
			executePlugin({ useSource: true }, samples, function(locales) {
				expect(locales['samples']['en']['xml_space_default']).to.be.equal('non-translatable');
				done();
			});
		});

		it('should use overrideLanguage option', function(done) {
			executePlugin({ overrideLanguage: 'fr'}, samples, function(locales) {
				expect(locales['samples']['fr']['basic']).to.be.equal('TEST-target');
				done();
			});
		});

		it('should fallback to source when enabled', function(done) {
			executePlugin({ useSourceFallback: true }, samples, function(locales) {
				expect(locales['samples']['en-test']['no_target']).to.be.equal('source');
				done();
			});			
		});
		it('should not provide translation to source when fallback not enabled', function(done) {
			executePlugin({ }, samples, function(locales) {
				expect(locales['samples']['en-test']['no_target']).to.be.undefined;
				done();
			});			
		});
		it('should not provide translation to source when fallback is disabled', function(done) {
			executePlugin({ useSourceFallback: false }, samples, function(locales) {
				expect(locales['samples']['en-test']['no_target']).to.be.undefined;
				done();
			});			
		});
		it('should provide available target when fallback is enabled', function(done) {
			executePlugin({ useSourceFallback: true }, samples, function(locales) {
				expect(locales['samples']['en-test']['target']).to.be.equal('target');
				done();
			});			
		});
	});
});
