Package.describe({
  name: 'rriemann:nodemailer',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'Nodemailer wrapper for Meteor',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'nodemailer': '1.10.0',
  'nodemailer-stub-transport': '1.0.0'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2.1');
  api.use('coffeescript');
  api.use('ecmascript');
  api.addFiles('nodemailer.coffee', 'server');
  api.export('Nodemailer', 'server');
  api.export('NodemailerStubTransport','server');
});
