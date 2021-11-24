
# flack

[![tests](https://github.com/floraison/flack/workflows/test/badge.svg)](https://github.com/floraison/flack/actions)
[![Gem Version](https://badge.fury.io/rb/flack.svg)](http://badge.fury.io/rb/flack)

Flack is a Rack app for the [flor](https://github.com/floraison/flor) workflow engine.


## test ride

```sh
make migrate
make start
open http://localhost:7007/
```

Warning: this serves an API, not some fancy web interface.


## api

Based on HAL ([spec](http://stateless.co/hal_specification.html) and [draft](https://tools.ietf.org/html/draft-kelly-json-hal-08)), [URI Template](https://tools.ietf.org/html/rfc6570), and [CURIE](https://www.w3.org/TR/curie/).


## in a rack app

```ruby
map '/flack' do

  run Flack::App.new('flor/')
    # starts a flack app whose flor unit uses the tree at flor/
end
```


## license

MIT, see [LICENSE.txt](LICENSE.txt)

