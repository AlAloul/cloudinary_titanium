exports.execute = function() {
    var jasmine = require('spec/lib/jasmine-1.2.0').jasmine;
    var reporter = require('spec/lib/reporter').TitaniumReporter;
    Ti.include('/spec/env.js');

    require('cloudinary_spec');
    require('uploader_spec');

    jasmine.getEnv().addReporter(new reporter());
    jasmine.getEnv().execute();
};

