// Generated by CoffeeScript 1.6.2
(function() {
  var VEvent;

  VEvent = (function() {
    function VEvent(point, pe) {
      this.point = point;
      this.pe = pe;
      this.y = this.point.y;
      this.key = Math.random() * 100000000;
      this.arch = null;
      this.value = 0;
    }

    VEvent.prototype.compare = function(other) {
      if (this.y - other.y) {
        return 1;
      } else {
        return -1;
      }
    };

    return VEvent;

  })();

}).call(this);
