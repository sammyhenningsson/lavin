# Lavin

Lavin is a tool for testing how your website is handling load/traffic.
It's based on the [Async](https://github.com/socketry/async) framework. This means it uses event driven IO and light weight Fibers.
(Lavin means "avalanche" in swedish. I thought it was a nice and short suitable name. 😀)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lavin'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lavin

## Usage

Configure one or more user classes by inherting from `Lavin::User`. E.g:
```ruby
# users/my_user.rb

require 'lavin'

class MyUser < Lavin::User
  step do
    puts "hello world"
  end
end
```

This class will have the following class methods:
 - `.name(str = nil)`: Sets/gets a name for this user. Defaults to the class name.
 - `.description(str = nil)`: "Sets/gets a description for this user.
 - `.enabled(status)`: Specifies if this user should be used.
 - `.user_count(number)`: Specifies the number of user instances that should be spawned.
 - `.iterations(number)`: Specifies the number of iterations every user should run. `-1` means runs forever. Default: `1`.
 - `.base_url(number)`: Specifies a base url that should be used for http requests.

 - `.before(&block)`: Defines a block that will run when a user is started.
 - `.after(&block)`: Defines a block that will run a user has finished all iterations.
 - `.step(name: nil, repeat: 1, &block)`: Defines a "unit of work". The blocks will run in the context of a `User` instance.


As well as the following instance methods:
 - `#name`: Returns the name of the user.
 - `#description`: Returns the description of the user.
 - `#success`: Finish a step and mark it successful.
 - `#success!`: Finish the user (and all remaining steps), marking the current step as successful.
 - `#failure(msg)`: Finish a step and mark it as a failure.
 - `#failure!(msg)`: Finish the user (and all remaining steps), marking the current step as a failure.
 - `#sleep(seconds)`: Sleep seconds. (This will not block he event loop)

The following instance methods will all make HTTP request and store statistics about them.
 - `#get(url, headers: {})`
 - `#head(url, headers: {})`
 - `#post(url, headers: {}, body: nil)`
 - `#put(url, headers: {}, body: nil)`
 - `#patch(url, headers: {}, body: nil)`
 - `#delete(url, headers: {})`  
 These methods all makes HTTP requests to `url`. If `base_url` is configured and `url` is relative (e.g `/foo/bar`), then `url` is prefixed with `base_url`.
 The return value is a `Hash` with the following properties:
 - `status`: The HTTP status code.
 - `headers`: The HTTP response headers.
 - `body`: The response body.

The tool is started with the `lavin` command (installed with the gem) which takes one or more files as arguments. These files must be files defining users or a directory which includes files with users. E.g:
```sh
$ lavin foo_user.rb bar_users/
```
If the option `--no-web` is given, then it will run in the terminal and print the result to stdout. (Note currently this mode should not be used with `iterations -1`, since it will run forever. Stopping with `Ctrl+C` will not print any results).
Without the `--no-web` option a sinatra web server will be started on localhost port 1080. It will look something like this:
![Start screen](/start_screen.png)
Here you can change the configuration of user and start a new load test.

## Examples
See the [WebUser example file](examples/web_user.rb) for some more details about how to write user files. But basically, its really quite simple just define a class and create `step` blocks for things that should be performed. Other than that its just plain ruby. So, simply require additional file with more business logic and make use if it from inside the steps.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sammyhenningsson/lavin.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
