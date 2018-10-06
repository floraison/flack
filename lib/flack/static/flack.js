
window.clog = console.log;
window.cerr = console.error;


var Flack = (function() {

  "use strict";

  var self = this;

  // protected functions

  var renderExecutions = function(res) {

clog(res);
  };

  // public functions

  this.loadExecutions = function() {

    H.request('GET', 'executions', renderExecutions);
  };

  // done.

  return this;

}).apply({}); // end Flack

