'use strict';

import {danger, fail, warn} from 'danger';

const modifiedFiles = danger.git.modified_files;
const pr = danger.github.pr;

// Fail if the PR body is empty or very short.
if (!pr.body || pr.body.length < 10) {
    fail('Please add a description to your Pull Request.');
}

// Warn if digest of Dockerfile has been updated and point out files that need to be updated too.
if (modifiedFiles.includes('Dockerfile')) {
    const title = 'Dockerfile digest update';
    const filesWithVersion = danger.github.utils.fileLinks(['Dockerfile.latex']);
    const idea = `Please update ${filesWithVersion} before merging.`;
    warn(`${title} - <i>${idea}</i>`);
}

// Warn if version has been updated and point out files that need to be updated too.
if (modifiedFiles.includes('requirements.pip')) {
    const title = 'Version update';
    const filesWithVersion = danger.github.utils.fileLinks(['README.md', 'package.json']);
    const idea = `Please update ${filesWithVersion} before merging.`;
    warn(`${title} - <i>${idea}</i>`);
}
