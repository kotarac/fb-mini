# fb-mini


## Install

```sh
npm install --save fb-mini
```


## Usage

```js
var fb = require('fb-mini');

fb.get('v2.4/me', 'someaccesstoken', function(err, response, statusCode) {
	console.log(response, statusCode);
});
```


## License

MIT © Stipe Kotarac (https://github.com/kotarac)
