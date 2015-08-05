# FunCSS

![Build status](https://travis-ci.org/funcss-lang/funcss.svg)

FunCSS is an extension of the CSS language where you can define custom functions in JavaScript that run **in the browser**. So, unlike CSS preprocessor, it compiles CSS-like code to JavaScript.

FunCSS is in the alpha phase and the language is subject to change. Do NOT use it in production.

## Introduction

For some function definition examples, head on to the standard library in [stdlib/](https://github.com/funcss-lang/funcss/tree/master/stdlib/vanilla-1.0.0.fcss).

For an introduction about the project, see the slides of [my thesis presenatation](http://cie.web.elte.hu/funcss/slideshow) about FunCSS.

## What it can do that CSS preprocessors can't

* Styles depending on run-time data (e.g. current time)
* Some event handling
* Polyfill `vw`, `vh`, `vmin`, `vmax`

## How it works?

FunCSS is based on Meteor.js's [Tracker](https://meteor.com/projects/tracker) library for handling reactive updating of styles.

## Future plans

* Reimplement the compiler as a PostCSS plugin pack
* Add support for custom selectors, properties, media queries etc., all of which evaluated in the browser
* Add better event handling support


