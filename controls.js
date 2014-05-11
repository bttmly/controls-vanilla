(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var BaseControl, defaults, extend;

extend = require("./utilities.coffee").extend;

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
    if (!(el instanceof Element)) {
      console.log(el);
    }
    this.el = el;
    this.id = el.getAttribute(settings.identifyingAttribute);
    this.type = el.type || el.tagName.toLowerCase();
    this.tag = el.tagName.toLowerCase();
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

  BaseControl.prototype.clear = function(squelchEvent) {
    if (this.el.value) {
      this.el.value = "";
      return this.dispatchEvent("change");
    }
  };

  BaseControl.prototype.addEventListener = function(eventType, handler) {
    handler = handler.bind(this);
    this.el.addEventListener(eventType, handler);
    return handler;
  };

  BaseControl.prototype.removeEventListener = function(eventType, handler) {
    return this.el.removeEventListener(handler);
  };

  BaseControl.prototype.dispatchEvent = function(evt) {
    if (typeof evt === "string") {
      evt = new Event(evt, {
        bubbles: true
      });
    }
    if (evt instanceof Event) {
      return this.el.dispatchEvent(evt);
    } else {
      throw new TypeError("Pass a string or Event object to dispatchEvent!");
    }
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
    ButtonControl.__super__.constructor.call(this, arguments);
    this.el.type = "button";
    this.type = "button";
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

  CheckableControl.prototype.checked = function(param) {
    var initial;
    initial = this.el.checked;
    if ((param != null) && param !== initial) {
      this.el.checked = param;
      this.dispatchEvent("change");
    }
    return this.el.checked;
  };

  CheckableControl.prototype.clear = function() {
    if (this.checked()) {
      return this.checked(false);
    }
  };

  return CheckableControl;

})(BaseControl);

module.exports = CheckableControl;


},{"./base-control.coffee":1}],4:[function(require,module,exports){
var ControlCollection, each, extend, isEmpty, mapToObj, validation, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

_ref = require("./utilities.coffee"), extend = _ref.extend, isEmpty = _ref.isEmpty, each = _ref.each, mapToObj = _ref.mapToObj;

validation = require("./validation.coffee");

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
    var component, settings, _i, _len;
    this.collections = {};
    for (_i = 0, _len = components.length; _i < _len; _i++) {
      component = components[_i];
      if (component instanceof ControlCollection) {
        this.collections[component.id] = component;
        this.push.apply(this, component);
      } else {
        this.push(component);
      }
    }
    this.els = this.map(function(c) {
      return c.el;
    });
    settings = extend({}, ControlCollection.defaults(), options);
    this.id = settings.id;
  }

  ControlCollection.prototype.defaultValue = "valueAsObject";

  ControlCollection.prototype.value = function() {
    return this[this.defaultValue]();
  };

  ControlCollection.prototype.valueAsObject = function() {
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
    var m;
    m = mapToObj(this, function(component) {
      if (param != null) {
        component.disabled(param);
      }
      return [component.id, component.disabled()];
    });
    if (param) {
      return this;
    } else {
      return m;
    }
  };

  ControlCollection.prototype.required = function(param) {
    var m;
    m = mapToObj(this, function(component) {
      if (param != null) {
        component.required(param);
      }
      return [component.id, component.required()];
    });
    if (param) {
      return this;
    } else {
      return m;
    }
  };

  ControlCollection.prototype.checked = function(param) {
    var m;
    m = mapToObj(this, function(component) {
      if (param != null) {
        component.checked(param);
      }
      return [component.id, component.checked()];
    });
    if (param) {
      return this;
    } else {
      return m;
    }
  };

  ControlCollection.prototype.clear = function() {
    var component, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      component.clear();
    }
    return this;
  };

  ControlCollection.prototype.valid = function() {
    var checkedInSubCollection, collectionsValid, control, singlesValid, _i, _len;
    checkedInSubCollection = [];
    collectionsValid = true;
    each(this.collections, function(collection) {
      checkedInSubCollection.push.apply(checkedInSubCollection, collection);
      if (!collection.valid()) {
        return collectionsValid = false;
      }
    });
    singlesValid = true;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      control = this[_i];
      if (__indexOf.call(checkedInSubCollection, control) >= 0) {
        continue;
      }
      if (!control.valid()) {
        singlesValid = false;
      }
    }
    return collectionsValid && singlesValid;
  };

  ControlCollection.prototype.addEventListener = function(eventType, handler, context) {
    var fn;
    if (context == null) {
      context = this;
    }
    fn = (function(_this) {
      return function(event) {
        var _ref1;
        if (_ref1 = event.target, __indexOf.call(_this.els, _ref1) >= 0) {
          if (context === "target") {
            context = event.target;
          } else if (context === "control") {
            context = _this.find({
              el: event.target
            });
          }
          return handler.call(context, event);
        }
      };
    })(this);
    document.addEventListener(eventType, fn);
    return fn;
  };

  ControlCollection.prototype.removeEventListener = function(eventType, handler) {
    return document.removeEventListener(eventType, handler);
  };

  ControlCollection.prototype.dispatchEvent = function(event) {
    var el, _i, _len, _ref1, _results;
    if (typeof event === "string") {
      event = new Event(event);
    }
    _ref1 = this.els;
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      el = _ref1[_i];
      _results.push(el.dispatchEvent(event));
    }
    return _results;
  };

  ControlCollection.prototype.where = function(obj) {
    var component, key, match, ret, val, _i, _len;
    ret = [];
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      component = this[_i];
      match = true;
      for (key in obj) {
        val = obj[key];
        if (component[key] !== val) {
          match = false;
        }
      }
      if (match) {
        ret.push(component);
      }
    }
    return ret;
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
      if (match) {
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


},{"./utilities.coffee":8,"./validation.coffee":9}],5:[function(require,module,exports){
window.Controls = require("./factory.coffee");


},{"./factory.coffee":6}],6:[function(require,module,exports){
var BaseControl, ButtonControl, CheckableControl, ControlCollection, Factory, SelectControl, buildControl, controlTags, extend, processSelector, qsa, validationFunctions, _ref,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

BaseControl = require("./base-control.coffee");

SelectControl = require("./select-control.coffee");

ButtonControl = require("./button-control.coffee");

CheckableControl = require("./checkable-control.coffee");

ControlCollection = require("./control-collection.coffee");

validationFunctions = require("./validation.coffee");

_ref = require("./utilities.coffee"), qsa = _ref.qsa, extend = _ref.extend, processSelector = _ref.processSelector;

controlTags = ["input", "select", "button", "textarea"];

buildControl = function(el) {
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
  var components, controls, _ref1;
  if (options == null) {
    options = {};
  }
  components = [];
  if (typeof element === "string") {
    options.id = processSelector(element);
    element = document.querySelector(element);
  }
  if (element instanceof Element) {
    if (_ref1 = element.tagName.toLowerCase(), __indexOf.call(controlTags, _ref1) >= 0) {
      components.push(element);
    } else {
      Array.prototype.push.apply(components, qsa(element, controlTags.join(", ")));
    }
  } else if (element.length != null) {
    Array.prototype.forEach.call(element, function(el) {
      var _ref2;
      if ((el instanceof ControlCollection) || (el instanceof Element && (_ref2 = el.tagName.toLowerCase(), __indexOf.call(controlTags, _ref2) >= 0))) {
        return components.push(el);
      }
    });
  }
  controls = components.map(function(item) {
    if (item instanceof Element) {
      return buildControl(item);
    } else {
      return item;
    }
  });
  return new ControlCollection(controls, options);
};

Factory._validations = validationFunctions;

Factory.addValidation = function(key, val) {
  var fn;
  if (this._validation[key]) {
    return false;
  }
  if (val instanceof RegExp) {
    fn = function(str) {
      return val.match(str);
    };
  } else if (val instanceof Function) {
    fn = val;
  }
  return this._validation[key] = fn;
};

Factory.BaseControl = BaseControl;

Factory.SelectControl = SelectControl;

Factory.ButtonControl = ButtonControl;

Factory.CheckableControl = CheckableControl;

Factory.ControlCollection = ControlCollection;

module.exports = Factory;


},{"./base-control.coffee":1,"./button-control.coffee":2,"./checkable-control.coffee":3,"./control-collection.coffee":4,"./select-control.coffee":7,"./utilities.coffee":8,"./validation.coffee":9}],7:[function(require,module,exports){
var BaseControl, SelectControl, each, filter, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseControl = require("./base-control.coffee");

_ref = require("./utilities.coffee"), filter = _ref.filter, each = _ref.each;

SelectControl = (function(_super) {
  __extends(SelectControl, _super);

  function SelectControl() {
    return SelectControl.__super__.constructor.apply(this, arguments);
  }

  SelectControl.prototype.value = function() {
    var sel;
    sel = this.selected();
    if (!sel.length) {
      return;
    }
    if (sel.length > 1) {
      return sel.map(function(option) {
        return option.value;
      });
    } else {
      return sel[0].value;
    }
  };

  SelectControl.prototype.selected = function() {
    return filter(this.el.options, function(option) {
      return option.selected && !option.disabled;
    });
  };

  SelectControl.prototype.valid = function() {
    return !!this.value().length;
  };

  SelectControl.prototype.clear = function() {
    if (selected().length) {
      each(this.el.options, function(option) {
        return option.selected = false;
      });
      return this.dispatchEvent("change");
    }
  };

  return SelectControl;

})(BaseControl);

module.exports = SelectControl;


},{"./base-control.coffee":1,"./utilities.coffee":8}],8:[function(require,module,exports){
var camelize, each, extend, filter, isEmpty, map, mapAllTrue, mapToObj, processSelector, qsa, slice,
  __hasProp = {}.hasOwnProperty,
  __slice = [].slice;

extend = function(out) {
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
};

qsa = function() {
  var el, selector;
  if (arguments[0] instanceof Node) {
    el = arguments[0];
    selector = arguments[1];
  } else {
    el = document;
    selector = arguments[0];
  }
  return slice(el.querySelectorAll(selector));
};

slice = function() {
  var args, arr;
  arr = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  return Array.prototype.slice.apply(arr, args);
};

filter = function(arr, cb) {
  return Array.prototype.filter.call(arr, cb);
};

map = function(arr, cb) {
  return Array.prototype.map.call(arr, cb);
};

each = function(obj, itr) {
  var i, list, _results;
  list = Array.isArray(obj) ? obj.map(function(e, i) {
    return i;
  }) : Object.keys(obj);
  i = 0;
  _results = [];
  while (i < list.length) {
    itr(obj[list[i]], list[i], obj);
    _results.push(i += 1);
  }
  return _results;
};

camelize = function(str) {
  return str.replace(/(?:^|[-_])(\w)/g, function(_, c) {
    if (c) {
      return c.toUpperCase();
    } else {
      return "";
    }
  });
};

processSelector = function(str) {
  return camelize(str).replace(/\W/g, "");
};

mapAllTrue = function(arr, fn) {
  return arr.map(fn).every(function(item) {
    return !!item;
  });
};

mapToObj = function(arr, fn) {
  var i, keyVal, obj, _i, _len;
  obj = {};
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    i = arr[_i];
    keyVal = fn(i);
    if (Array.isArray(keyVal) && keyVal.length === 2) {
      obj[keyVal[0]] = keyVal[1];
    }
  }
  return obj;
};

isEmpty = function(obj) {
  if (Array.isArray(obj)) {
    return !!obj.length;
  } else {
    return !!Object.keys(obj).length;
  }
};

module.exports = {
  extend: extend,
  qsa: qsa,
  slice: slice,
  filter: filter,
  each: each,
  camelize: camelize,
  processSelector: processSelector,
  mapAllTrue: mapAllTrue,
  mapToObj: mapToObj,
  isEmpty: isEmpty
};


},{}],9:[function(require,module,exports){
var collectionValidations, controlValidations,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

controlValidations = {
  notEmpty: function() {
    return function(str) {
      return !!str;
    };
  },
  notEmptyTrim: function() {
    return function(str) {
      return !!str.trim();
    };
  },
  numeric: function() {
    return function(str) {
      return /^\d+$/.test(str);
    };
  },
  alphanumeric: function() {
    return function(str) {
      return /^[a-z0-9]+$/i.test(str);
    };
  },
  letters: function() {
    return function(str) {
      return /^[a-z]+$/i.test(str);
    };
  },
  isValue: function(value) {
    return function(str) {
      return str === value;
    };
  },
  email: (function() {
    var i;
    i = document.createElement("input");
    i.type = "email";
    return function() {
      return function(str) {
        i.value = str;
        return i.validity.valid;
      };
    };
  })(),
  allowed: function(allowedChars) {
    allowedChars = allowedChars.split("");
    return function(str) {
      var char, _i, _len;
      str = str.split("");
      for (_i = 0, _len = str.length; _i < _len; _i++) {
        char = str[_i];
        if (__indexOf.call(allowedChars, char) < 0) {
          return false;
        }
      }
      return true;
    };
  },
  notAllowed: function(notAllowedChars) {
    notAllowedChars = notAllowedChars.split("");
    return function(str) {
      var char, _i, _len;
      str = str.split("");
      for (_i = 0, _len = notAllowedChars.length; _i < _len; _i++) {
        char = notAllowedChars[_i];
        if (__indexOf.call(notAllowedChars, char) >= 0) {
          return false;
        }
      }
      return true;
    };
  },
  numberBetween: function(min, max) {
    return function(str) {
      var _ref;
      return (min <= (_ref = Number(str)) && _ref <= max);
    };
  },
  numberMax: function(max) {
    return validations.between(0, max);
  },
  numberMin: function(min) {
    return validations.between(min, Number.POSITIVE_INFINITY);
  },
  lengthBetween: function(min, max) {
    return function(str) {
      var _ref;
      return (min <= (_ref = str.length) && _ref <= max);
    };
  },
  lengthMax: function(max) {
    return validations.lengthBetween(0, max);
  },
  lengthMin: function(min) {
    return validations.lengthBetween(min, Number.POSITIVE_INFINITY);
  }
};

collectionValidations = {
  allValid: function() {
    return this.every(function(control) {
      return control.valid();
    });
  },
  allChecked: function() {
    return this.every(function(control) {
      return control.el.checked;
    });
  },
  anyChecked: function() {
    return this.some(function(control) {
      return control.el.checked;
    });
  },
  allHaveSelected: function() {
    return this.every(function(control) {
      return control.selected().legnth;
    });
  },
  anyHaveSelected: function() {
    return this.some(function(control) {
      return control.selected().length;
    });
  }
};

module.exports = controlValidations;


},{}]},{},[5])