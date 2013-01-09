// Generated by CoffeeScript 1.4.0
(function() {
  var Range, Restriction, Target, TargetSet;

  TargetSet = (function() {

    function TargetSet() {}

    TargetSet.targets = [];

    TargetSet._active = false;

    TargetSet._lastScroll = NaN;

    TargetSet.window = $(window);

    TargetSet.document = $(document);

    TargetSet.firefox = navigator.userAgent.toLowerCase().indexOf('firefox') > -1;

    TargetSet.save = function(element, conditions) {
      var id, target;
      id = element.data('stickletId');
      target = new Target(element, conditions);
      if (!this.targets[id]) {
        id = this.targets.length;
        element.data('stickletId', id);
        this.targets.push(target);
      } else {
        this.targets[id] = target;
      }
      return this.positionAll();
    };

    TargetSet.positionAll = function() {
      var target, _i, _len, _ref, _results;
      _ref = this.targets;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        target = _ref[_i];
        _results.push(target.position());
      }
      return _results;
    };

    TargetSet.activate = function() {
      if (!this._active) {
        this.window.on('scroll', this._onScroll);
        return this._active = true;
      }
    };

    TargetSet.deactivate = function() {
      this.window.off('scroll', this._onScroll);
      return this._active = false;
    };

    TargetSet.clear = function() {
      var target, _i, _len, _ref;
      _ref = this.targets;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        target = _ref[_i];
        target.reset();
      }
      return this.targets = [];
    };

    TargetSet._onScroll = function() {
      var scrollTop;
      scrollTop = TargetSet.window.scrollTop();
      if (scrollTop !== TargetSet._lastScroll) {
        TargetSet.positionAll();
        return TargetSet._lastScroll = scrollTop;
      }
    };

    return TargetSet;

  }).call(this);

  Target = (function() {

    function Target(element, conditions) {
      var condition, restriction, _i, _len;
      this.element = element.first() || $([]);
      this.element.css('position', 'fixed');
      this.initialOffset = this.element.offset().top;
      this.restrictions = [];
      for (_i = 0, _len = conditions.length; _i < _len; _i++) {
        condition = conditions[_i];
        restriction = new Restriction(this, condition);
        if (restriction.element.length > 0) {
          this.restrictions.push(restriction);
        }
      }
    }

    Target.prototype.position = function() {
      var correction, doc, range, win;
      range = this.getRange();
      win = TargetSet.window;
      doc = TargetSet.document;
      correction = TargetSet.firefox ? 0 : Math.max(0, Math.min(win.scrollTop(), doc.height() - win.height()));
      console.log('correction ' + correction);
      if (range.stickTo === 'top') {
        this.element.offset({
          top: range.min - correction
        });
        return console.log('min ' + range.min);
      } else {
        this.element.offset({
          top: range.max - correction
        });
        return console.log('max ' + range.max);
      }
    };

    Target.prototype.getRange = function() {
      var finalRange, range, restriction, _i, _len, _ref;
      finalRange = new Range;
      _ref = this.restrictions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        restriction = _ref[_i];
        range = restriction.calculate();
        if (range.stickTo === 'top') {
          if (range.min <= finalRange.max) {
            finalRange.min = Math.max(range.min, finalRange.min);
            finalRange.stickTo = 'top';
          } else {
            return finalRange;
          }
        } else {
          if (range.max >= finalRange.min) {
            finalRange.max = Math.min(range.max, finalRange.max);
            finalRange.stickTo = 'bottom';
          } else {
            return finalRange;
          }
        }
      }
      return finalRange;
    };

    Target.prototype.reset = function() {
      return this.element.offset({
        top: this.initialOffset
      });
    };

    return Target;

  })();

  Restriction = (function() {

    Restriction.regex = /^(below|above|topline|bottomline)\s+(\S+)$/;

    function Restriction(target, condition) {
      var match;
      this.target = target;
      this.condition = condition;
      match = Restriction.regex.exec(condition);
      this.position = match[1];
      this.selector = match[2];
      this.element = $(this.selector);
    }

    Restriction.prototype.calculate = function() {
      var rangeMap,
        _this = this;
      rangeMap = {
        below: function() {
          return {
            min: _this.element.offset().top + _this.element.height(),
            stickTo: 'top'
          };
        },
        topline: function() {
          return {
            min: _this.element.offset().top,
            stickTo: 'top'
          };
        },
        above: function() {
          return {
            max: _this.element.offset().top - _this.target.element.height(),
            stickTo: 'bottom'
          };
        },
        bottomline: function() {
          return {
            max: _this.element.offset().top + _this.element.height() - _this.target.element.height(),
            stickTo: 'bottom'
          };
        }
      };
      return new Range(rangeMap[this.position]());
    };

    return Restriction;

  })();

  Range = (function() {

    function Range(options) {
      this.min = (options ? options.min : void 0) || -Number.MAX_VALUE;
      this.max = (options ? options.max : void 0) || Number.MAX_VALUE;
      this.stickTo = (options ? options.stickTo : void 0) || 'top';
    }

    return Range;

  })();

  $.fn.sticklet = function() {
    var conditions;
    conditions = arguments;
    TargetSet.deactivate();
    this.each(function() {
      return TargetSet.save($(this), conditions);
    });
    TargetSet.activate();
    return this;
  };

}).call(this);
