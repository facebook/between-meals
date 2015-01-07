# Between Meals

[![Build Status](https://travis-ci.org/wjimenez5271/between-meals.svg)](https://travis-ci.org/wjimenez5271/between-meals)

A fork of Facebook's [Between Meals](https://github.com/facebook/between-meals)

## Intro
Ohai!

Between Meals is the library for calculating what Chef objects where modified
between two revisions in a version control system. It is also the library
that that backs Taste Tester and Grocery Delivery.

It currently supports SVN and GIT, but plugins can easily be written for
other systems.

It also includes some wrappers around knife execution and a few other utility
functions.

## Dependencies

* Colorize
* JSON
* Mixlib::ShellOut
* Rugged
