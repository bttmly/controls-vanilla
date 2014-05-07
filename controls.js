(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var BaseControl, defaults, extend, util;

util = require("./utilities.coffee");

extend = util.extend;

defaults = {
  identifyingAttribute: "id"
};

BaseControl = (function() {
  function BaseControl(el, options) {
    var settings;
    if (options == null) {
      options = {};
    }
    settings = extend({}, defaults, options);
    this.el = el;
    this.id = el.getAttribute(settings.identifyingAttribute);
  }

  BaseControl.prototype.required = function(param) {
    if (param != null) {
      this.el.required = !!param;
      return this;
    } else {
      return this.el.required;
    }
  };

  BaseControl.prototype.disabled = function(param) {
    if (param != null) {
      this.el.disabled = !!param;
      return this;
    } else {
      return this.el.disabled;
    }
  };

  BaseControl.prototype.value = function(param) {
    if (param != null) {
      this.el.value = param;
      return this;
    } else if (this.valid()) {
      return this.el.value;
    }
  };

  BaseControl.prototype.valid = function() {
    if (this.el.checkValidity) {
      return this.el.checkValidity();
    } else {
      return true;
    }
  };

  BaseControl.prototype.on = function(eventType, handler) {
    this.el.addEventListener(eventType, handler);
    return this;
  };

  BaseControl.prototype.off = function(handler) {
    this.el.removeEventListener(handler);
    return this;
  };

  BaseControl.prototype.trigger = function(eventType) {
    this.el.dispatchEvent(new CustomEvent(eventType));
    return this;
  };

  return BaseControl;

})();

module.exports = BaseControl;


},{"./utilities.coffee":8}],2:[function(require,module,exports){
var BaseControl, ButtonControl,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseControl = require("./base-control.coffee");

ButtonControl = (function(_super) {
  __extends(ButtonControl, _super);

  function ButtonControl() {
    return ButtonControl.__super__.constructor.apply(this, arguments);
  }

  ButtonControl.prototype.value = function() {
    return false;
  };

  return ButtonControl;

})(BaseControl);

module.exports = ButtonControl;


},{"./base-control.coffee":1}],3:[function(require,module,exports){
var BaseControl, CheckableControl,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseControl = require("./base-control.coffee");

CheckableControl = (function(_super) {
  __extends(CheckableControl, _super);

  function CheckableControl() {
    return CheckableControl.__super__.constructor.apply(this, arguments);
  }

  CheckableControl.prototype.value = function(param) {
    if (param) {
      this.el.value = param;
      return this;
    } else {
      if (this.el.checked) {
        return this.el.value;
      } else {
        return false;
      }
    }
  };

  return CheckableControl;

})(BaseControl);

module.exports = CheckableControl;


},{"./base-control.coffee":1}],4:[function(require,module,exports){
var ControlCollection, extend, util,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

util = require("./utilities.coffee");

extend = util.extend;

ControlCollection = (function(_super) {
  __extends(ControlCollection, _super);

  ControlCollection.defaults = (function() {
    var counter;
    counter = 0;
    return function() {
      return {
        id: (function() {
          counter += 1;
          return "controlCollection" + counter;
        })()
      };
    };
  })();

  function ControlCollection(components, options) {
    var component, controls, settings, _i, _len;
    controls = [];
    this.collections = {};
    for (_i = 0, _len = components.length; _i < _len; _i++) {
      component = components[_i];
      if (component instanceof ControlCollection) {
        this.collections[component.id] = component;
        [].push.apply(this, component);
      } else {
        this.push(component);
      }
    }
    settings = extend({}, ControlCollection.defaults(), options);
    this.id = settings.id;
  }

  ControlCollection.prototype.value = function() {
    var component, val, values, _i, _len;
    values = {};
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      val = component.value();
      if (val && val.length) {
        values[component.id] = val;
      }
    }
    return values;
  };

  ControlCollection.prototype.valueAsArray = function() {
    var component, val, values, _i, _len;
    values = [];
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      val = component.value();
      if (val && val.length) {
        values.push({
          id: component.id,
          val: val
        });
      }
    }
    return values;
  };

  ControlCollection.prototype.disabled = function(param) {
    var component, results, _i, _len;
    results = {};
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      if (param != null) {
        component.disabled(param);
      }
      results[component.id] = component.disabled();
    }
    return results;
  };

  ControlCollection.prototype.required = function(param) {
    var component, results, _i, _len;
    results = {};
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      if (param != null) {
        component.required(param);
      }
      results[component.id] = component.required();
    }
    return results;
  };

  ControlCollection.prototype.on = function(eventType, handler) {
    var component, _i, _len;
    handler = handler.bind(this);
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      component.on(eventType, handler);
    }
    return this;
  };

  ControlCollection.prototype.off = function() {
    var component, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      component.off(arguments);
    }
    return this;
  };

  ControlCollection.prototype.trigger = function(eventType, handler) {
    var component, _i, _len;
    handler = handler.bind(this);
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      component.trigger(arguments);
    }
    return this;
  };

  ControlCollection.prototype.where = function(obj) {
    var component, key, match, ret, val, _i, _len, _results;
    ret = [];
    _results = [];
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      match = true;
      for (key in obj) {
        val = obj[key];
        if (component[key] !== val) {
          match = false;
        }
      }
      if (match === true) {
        _results.push(ret.push(component));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  ControlCollection.prototype.find = function(obj) {
    var component, key, match, val, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      match = true;
      for (key in obj) {
        val = obj[key];
        if (component[key] !== val) {
          match = false;
        }
      }
      if (match === true) {
        return component;
      }
    }
  };

  ControlCollection.prototype.byId = function(id) {
    return this.find({
      id: id
    });
  };

  return ControlCollection;

})(Array);

module.exports = ControlCollection;


},{"./utilities.coffee":8}],5:[function(require,module,exports){
(function(root, factory) {
  root = window;
  return root.Controls = factory(root, {});
})(this, function(root, Controls) {
  Controls = require("./factory.coffee");
  return Controls;
});


},{"./factory.coffee":6}],6:[function(require,module,exports){
var BaseControl, ButtonControl, CheckableControl, ControlCollection, Factory, SelectControl, buildControl, controlTags, defaults, extend, qsa, utilities,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

BaseControl = require("./base-control.coffee");

SelectControl = require("./select-control.coffee");

ButtonControl = require("./button-control.coffee");

CheckableControl = require("./checkable-control.coffee");

ControlCollection = require("./control-collection.coffee");

utilities = require("./utilities.coffee");

qsa = utilities.qsa;

extend = utilities.extend;

controlTags = ["input", "select", "button", "textarea"];

defaults = buildControl = function(el) {
  switch (el.tagName.toLowerCase()) {
    case "input" || "textarea":
      if (el.type === "radio" || el.type === "checkbox") {
        return new CheckableControl(el);
      } else {
        return new BaseControl(el);
      }
      break;
    case "select":
      return new SelectControl(el);
    case "button":
      return new ButtonControl(el);
    default:
      throw new TypeError("Non-control element passed!");
  }
};

Factory = function(element, options) {
  var components, controls, el, settings, _ref;
  if (options == null) {
    options = {};
  }
  settings = extend({}, defaults, options);
  components = [];
  if (typeof element === "string") {
    el = document.querySelector(element);
    if (_ref = el.tagName.toLowerCase(), __indexOf.call(controlTags, _ref) >= 0) {
      components.push(el);
    } else {
      Array.prototype.push.apply(components, qsa(el, controlTags.join(", ")));
    }
  } else if (element.length != null) {
    Array.prototype.forEach.call(element, function(el) {
      var _ref1;
      if ((el instanceof ControlCollection) || (el instanceof Element && (_ref1 = el.tagName.toLowerCase(), __indexOf.call(controlTags, _ref1) >= 0))) {
        return components.push(el);
      }
    });
  }
  controls = components.map(buildControl);
  return new ControlCollection(controls, settings);
};

Factory.BaseControl = BaseControl;

Factory.SelectControl = SelectControl;

Factory.ButtonControl = ButtonControl;

Factory.CheckableControl = CheckableControl;

Factory.ControlCollection = ControlCollection;

module.exports = Factory;


},{"./base-control.coffee":1,"./button-control.coffee":2,"./checkable-control.coffee":3,"./control-collection.coffee":4,"./select-control.coffee":7,"./utilities.coffee":8}],7:[function(require,module,exports){
var BaseControl, SelectControl, filter, utilities,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseControl = require("./base-control.coffee");

utilities = require("./utilities.coffee");

filter = utilities.filter;

SelectControl = (function(_super) {
  __extends(SelectControl, _super);

  function SelectControl() {
    return SelectControl.__super__.constructor.apply(this, arguments);
  }

  SelectControl.prototype.value = function() {
    var option, results, _i, _len, _ref;
    results = [];
    _ref = this.selected();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      option = _ref[_i];
      if (option.value) {
        results.push(option.value);
      }
    }
    return results;
  };

  SelectControl.prototype.selected = function() {
    return filter(this.el.querySelectorAll("option"), function(opt) {
      return opt.selected && opt.value && !opt.disabled;
    });
  };

  return SelectControl;

})(BaseControl);

module.exports = SelectControl;


},{"./base-control.coffee":1,"./utilities.coffee":8}],8:[function(require,module,exports){
var utilities,
  __hasProp = {}.hasOwnProperty,
  __slice = [].slice;

utilities = {
  extend: function(out) {
    var i, key, _ref;
    out || (out = {});
    i = 1;
    while (i < arguments.length) {
      if (!arguments[i]) {
        continue;
      }
      _ref = arguments[i];
      for (key in _ref) {
        if (!__hasProp.call(_ref, key)) continue;
        out[key] = arguments[i][key];
      }
      i++;
    }
    return out;
  },
  qsa: function() {
    var el, selector;
    if (arguments[0] instanceof Node) {
      el = arguments[0];
      selector = arguments[1];
    } else {
      el = document;
      selector = arguments[0];
    }
    return utilities.slice(el.querySelectorAll(selector));
  },
  slice: function() {
    var args, arr;
    arr = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return Array.prototype.slice.apply(arr, args);
  },
  filter: function(arr, cb) {
    return Array.prototype.filter.call(arr, cb);
  }
};

module.exports = utilities;


},{}]},{},[5])