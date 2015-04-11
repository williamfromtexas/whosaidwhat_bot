// Our Twitter library
var Twitter = require('node-twitter');
// We need to include our configuration file
var conf = (require('./config.js'));

var img = (require('./img-to-tweet.js'));


var twitterRestClient = new Twitter.RestClient(
	conf.consumer_key,
	conf.consumer_secret,
	conf.access_token,
	conf.access_token_secret
);

twitterRestClient.statusesUpdateWithMedia({
        'status': 'Who said it? #imagebot #' + img.imagewho,
        'media[]': 'images/image-' + img.imagedate + '-' + img.imagehash + '-fin.jpg'
    },
    function(error, result) {
        if (error)
        {
            console.log('Error: ' + (error.code ? error.code + ' ' + error.message : error.message));
        }
        if (result)
        {
            console.log(result);
        }
    }
);

