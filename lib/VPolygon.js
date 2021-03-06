// Generated by CoffeeScript 1.6.2
(function() {
  var VPolygon;

  VPolygon = (function() {
    function VPolygon() {
      this.size = 0;
      this.verticies = [];
      this.first = null;
      this.last = null;
    }

    VPolygon.prototype.addRight = function(p) {
      this.verticies.push(p);
      this.size++;
      this.last = p;
      if (this.size === 1) {
        return this.first = p;
      }
    };

    VPolygon.prototype.addLeft = function(p) {
      this.verticies.unshift(p);
      this.size++;
      this.first = p;
      if (this.size === 1) {
        return this.last = p;
      }
    };

    return VPolygon;

  })();

}).call(this);
