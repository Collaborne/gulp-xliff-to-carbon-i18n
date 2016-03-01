const download = require('url-download');

download('http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd', '.')
	.on('close', function() {
		console.log('Schema downloaded successfully');
	});
