# Between Meals

![Continuous Integration](https://github.com/facebook/between-meals/workflows/Continuous%20Integration/badge.svg?event=push)

- [Intro](#Intro)
- [Dependencies](#Dependencies)
- [How to Install](#Intro)
- [License](#License)
  

<a id="Intro"></a>
## Intro
Ohai!

Between Meals is the library for calculating what Chef objects were modified
between two revisions in a version control system. It is also the library
that backs Taste Tester and Grocery Delivery.

It currently supports SVN, GIT and HG, but plugins can easily be written for
other source control systems.

It also includes some wrappers around knife execution and a few other utility
functions.

<a id="Dependencies"></a>
## Dependencies

* [Colorize](https://github.com/fazibear/colorize)
* [Mixlib::ShellOut](https://github.com/chef/mixlib-shellout)
* [Rugged](https://github.com/libgit2/rugged)

<a id="Install"></a>
## How to Install

* GEMFILE
  ```
  gem 'between_meals', '~> 0.0.12'
  ```
* INSTALL
  ```
  gem install between_meals
  ```
<a id="License"></a>
## License

See the `LICENSE` file in this repo.
