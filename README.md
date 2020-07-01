# Between Meals

![Continuous Integration](https://github.com/facebook/between-meals/workflows/Continuous%20Integration/badge.svg?event=push)

## Intro
Ohai!

Between Meals is the library for calculating what Chef objects were modified
between two revisions in a version control system. It is also the library
that backs Taste Tester and Grocery Delivery.

It currently supports SVN, GIT and HG, but plugins can easily be written for
other source control systems.

It also includes some wrappers around knife execution and a few other utility
functions.

## Dependencies

* Colorize
* Mixlib::ShellOut
* Rugged

## License

See the `LICENSE` file in this repo.
