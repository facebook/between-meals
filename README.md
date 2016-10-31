# Between Meals

[![Build Status](https://travis-ci.org/facebook/between-meals.svg)](http://travis-ci.org/facebook/between-meals)

## Intro
Ohai!

Between Meals is the library for calculating what Chef objects where modified
between two revisions in a version control system. It is also the library
that backs Taste Tester and Grocery Delivery.

It currently supports SVN, GIT and HG, but plugins can easily be written for
other source control systems.

It also includes some wrappers around knife execution and a few other utility
functions.

## Dependencies

* Colorize
* JSON
* Mixlib::ShellOut
* Rugged

