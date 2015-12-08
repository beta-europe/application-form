# Nodemailer for Meteor

Please find the full documentation here:
<https://github.com/andris9/Nodemailer/blob/v1.10.0/README.md>

## TL;DR Usage Example

This is a complete example to send an e-mail with plaintext and HTML body

```javascript
var nodemailer = require('nodemailer');

// create reusable transporter object using SMTP transport
var transporter = nodemailer.createTransport({
    service: 'Gmail',
    auth: {
        user: 'gmail.user@gmail.com',
        pass: 'userpass'
    }
});

// NB! No need to recreate the transporter object. You can use
// the same transporter object for all e-mails

// setup e-mail data with unicode symbols
var mailOptions = {
    from: 'Fred Foo ✔ <foo@blurdybloop.com>', // sender address
    to: 'bar@blurdybloop.com, baz@blurdybloop.com', // list of receivers
    subject: 'Hello ✔', // Subject line
    text: 'Hello world ✔', // plaintext body
    html: '<b>Hello world ✔</b>' // html body
};

// send mail with defined transport object
transporter.sendMail(mailOptions, function(error, info){
    if(error){
        return console.log(error);
    }
    console.log('Message sent: ' + info.response);

});
```

You may need to ["Allow Less Secure Apps"](https://www.google.com/settings/security/lesssecureapps) in your gmail account (it's all the way at the bottom). You also may need to ["Allow access to your Google account"](https://accounts.google.com/DisplayUnlockCaptcha)

See [nodemailer-smtp-transport](https://github.com/andris9/nodemailer-smtp-transport#usage) for SMTP configuration options and [nodemailer-wellknown](https://github.com/andris9/nodemailer-wellknown#supported-services) for preconfigured service names (example uses 'gmail').

> When using default SMTP transport, then you do not need to define transport type explicitly (even though you can), just provide the SMTP options and that's it. For anything else, see the docs of the particular [transport mechanism](#available-transports).
