'use strict';

var libxslt = require('libxslt');
var es = require('event-stream');
var gutil = require('gulp-util');
var fs = require('fs');
var path = require('path');

module.exports = function(config) {
	var stylesheet;

	// Load the template
	try {
		var contents = fs.readFileSync(path.join(__dirname, 'xliff-to-carbon-i18n.xsl'));
		// XXX: using #parse() directly fails with a coredump ...
		var stylesheetRaw = libxslt.libxmljs.parseXml(contents);
		stylesheet = libxslt.parse(stylesheetRaw);
	} catch (e) {
		throw new Error(e.message);
	}

	var useSource = config ? config.useSource : false;

	function processXLIFF(file, cb) {
		function throwError(message) {
			return cb(new gutil.PluginError('gulp-xliff-to-carbon-i18n', message));
		}

		if (file.isNull()) {
			return cb(null, file);
		}

		if (!file.isBuffer()) {
			return throwError('Streaming not supported');
		}

		try {
			var document = libxslt.libxmljs.parseXml(file.contents);
			var language = document.get('/xliff:xliff/xliff:file/@' + (useSource ? 'source-language' : 'target-language'), { 'xliff': 'urn:oasis:names:tc:xliff:document:1.2'}).value();
			var contents =  stylesheet.apply(document, {
				'use-source': useSource ? 'true' : 'false',
				'basename': path.basename(file.path, '.xliff'),
				'xliff-schema-uri': path.join(__dirname, 'xliff-core-1.2-strict.xsd')
			}, { outputFormat: 'string' });

			var resultFile = new gutil.File({
				base: file.base,
				cwd: file.cwd,
				path: gutil.replaceExtension(file.path, '.' + language + '.i18n.js'),
				contents: new Buffer(contents)
			});
			return cb(null, resultFile);
		} catch (e) {
			return throwError(e.message);
		}
	}

	return es.map(processXLIFF);
};
