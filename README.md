![Wraith v0.1.0](http://github.com/shaunspringer/wraith/raw/master/assets/wraith.gif "Wraith v0.1b")


## v0.1.0 [![Build Status](https://travis-ci.org/ShaunSpringer/Wraith.png?branch=master)](https://travis-ci.org/ShaunSpringer/Wraith)
#### Created by Shaun Springer

#### Meet Wraith
Wraith was a project I thought up several months ago out of my frustrations with the current MV* frameworks available on the internet. I was working on a few small, single page applications and was testing different frameworks to see which suit my needs. I used Backbone, Spine, Angular, and a few others that didn’t quite fit the bill. What I wanted was a framework that bound the data to the view, something I call implicit model-view binding, but required no logic to be present inside the views.

For all intents and purposes, Angular does provide this level of functionality, and so does Backbone, with the help from a variety of different plugins. But Angular is rather big, has a pretty steep learning curve, and doesn’t enforce logicless views (something I feel is extremely important in such a framework), and Backbone takes a bit of finagling to get anything to work quite right. Additionally all of these frameworks work best when used with a library like jQuery, or Zepto to handle event delegation and DOM manipulation.

#### Why make another MV* Framework?
I wrote Wraith because wanted a MV* framework that didn’t depend on any external libraries, had Angular-like Model-View binding, and was super lightweight and easy to understand. Additionally I wanted to write this framework in CoffeeScript since it is easy to read, has powerful array comprehension, and is just a ton of fun to write in.

Along the way I sought inspiration from Spine, Backbone and Angular, mixing Spine-style Models and Collections, Angular style directives, with Backbone style templating (a la Handlebars). All of these inspirations make Wraith a unique experience, but still feeling incredibly familiar to most frontend developers.

#### What makes Wraith different?
Wraith is completely self contained. You need nothing else to get started creating a basic single page application. I say basic because the framework is very much in its infancy. It does not have support for URL routing, AJAX requests, animations, or persistent storage.  All things I hope to accomplish in the near future.

Now that I have identified what Wraith doesn’t have, lets talk about what it does well.

* Implicit Model-View binding
* Controllers that are also views (a la View-Controller pattern)
* Handlebars-esque logicless templating
* Template declaration directly in the DOM that doesn’t require a compilation process
* Event binding directly from the DOM, instead of requiring JS to do so
* Partial view updating (only update elements that changed)
* Well under 20kb when minified

#### How to get started with wraith?
Wraith is declarative, in that much of the heavy lifting -- data and event binding, class and text manipulation -- happens directly in the markup (HTML). Your controller is initialized from the DOM directly, so when you create your app it’ll look something like this:

```html
<section data-controller=”App.MainController”>
  …
</section>
```

Wraith will require you to create an App.MainController object in the global namespace, that it will find, and create an instance of, binding it to the element that its defined on (in this case, section).

```javascript
var App = {};
App.MainController = (function(_super) {
	function MainController() {
		_super.call();
		this.registerModel(App.List, ‘list’) # Register our model as this.list
	}
	MainController.prototype.onCheckboxClick = function(e) {
		alert(e);
	}
	return MainController;
})(Wraith.Controller);
```

Before Wraith will do anything though, you must initialize its bootloader. This will start the controller initialization.

```html
<script type=”text/javascript”>
	new Wraith.Bootloader(); // My app is starting!
</script>
```

#### Event Handling
In Wraith, you are required to create event handlers in your controllers, but you bind them to events inside the DOM structure like so:

```html
<section data-controller=”App.MainController”>
	<input type=”text” data-events=”keypress;onCheckboxKeypress” />
	<div data-bind=”list.items” data-repeat>
		{{text}}
	</div>
</section>
```

Now when the text input is typed into, the onCheckboxKeypress method on App.MainController will be invoked.

#### Models and Collections
I really enjoyed working with Models in Spine when compared to other frameworks, and thus Wraith’s models are similar in design. You can create a new model with default values easily:

Coffeescript:
```coffeescript
	class App.ListItem extends Wraith.Model
		@field 'text', { default: 'New Item' }
		@field 'selected', { default: false }
```

Javascript:
```javascript
App.ListItem = (function(_super) {
	function ListItem() {
		_super.call();
		this.field('text', { default: 'New Item' };
		this.field('selected', { default: false };
	}
  	return ListItem;
})(Wraith.Model);
```

Collections can be done similarly:

Coffeescript:
```coffeescript
	class App.List extends Wraith.Model
		@hasMany App.ListItem, 'items'
```

Javascript:
```javascript
App.List = (function(_super) {
	function List() {
		_super.call();
		this.hasMany(App.ListItem, 'items');
	}
	return List;
})(Wraith.Model);
```

#### Data Binding
One of the most important things I tried to accomplish with Wraith was easy data binding. I didn’t want to write logic in my views, so I needed to handle looping over collections as well as showing and hiding views or partial views. The solution was to allow a view to be bound via dot-notation to a property on a model similar to what Angular does.

```html
<section data-controller=”App.MainController”>
	<input type=”text” data-events=”keypress;onCheckboxKeypress” />
	<div data-bind=”list.items” data-repeat>
		{{text}}
	</div>
</section>
```

This will bind the input to the list property on your controller (App.MainController). Every time the list.items property changes, the view will automatically be updated (and in this case, repeated as a list).

#### Class Binding
Want to hide or show something? Instead of writing logic in javascript to hide and show an element or alter its class attributes, you can use data or methods from your models to alter the class structure.

```html
<section data-controller=”App.MainController”>
<input type=”text” data-events=”keypress;onCheckboxKeypress” />
	<div data-bind=”list.items” data-repeat>
		<span data-class=”highlight:selected”>
			{{text}}
		</span>
	</div>
</section>
```

When selected is true, the class highlight will be applied to the span surrounding our text.

## Building and Testing
In order to build Wraith you will have to install several dependencies, do this with node (npm).

To install all the dependencies to build and run wraith, clone or fork this repository, and then run

```
npm install
```

This will run the installation file for the node dependencies. Next run

```
cake build
```

Which will build the source files, tests, and examples

To run the tests in browser or view the examples, use

```
cake server
```

This will start a server on port 8000, making tests and examples available for browsing.
* Tests are located at [http://localhost:8000/tests/SpecRunner.html](http://localhost:8000/tests/SpecRunner.html)
 	* Note: Tests can be run as headless with the command ```npm test```
* Examples are located at [http://localhost:8000/examples/](http://localhost:8000/examples/)

To run the tests in a headless browser (using phantomjs) run

```
cake test
```
