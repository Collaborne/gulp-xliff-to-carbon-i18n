#!/usr/bin/env node

'use strict';

const spawn = require('child_process').spawn;

const npm = spawn('npm', [ '--version' ]);
npm.stdout.on('data', (data) => {
    const version = data.toString().trim();
    console.log(`Detected NPM version: ${version}`);
    const v = version.toString().split(/\./);
    if (Number(v[0]) >= 5) {
        console.error(`Cannot install with npm 5.x: See https://github.com/npm/npm/issues/16824`);
        process.exit(1);
    }
});
