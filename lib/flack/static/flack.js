
window.clog = console.log;
window.cerr = console.error;


var Flack = (function() {

  "use strict";

  var self = this;

  // protected functions

  var onPostMessage = function(res) {

    self.loadExecutions();
  };

  var launchSubmit = function(ev) {

    ev.preventDefault();

    var j = {};
    j.point = 'launch';
    j.domain = H.elt('form#launch [name="domain"]').value;
    j.tree = H.elt('form#launch [name="tree"]').value;

    H.request('POST', 'message', j, onPostMessage);

    return false;
  };

  var reworkExecution = function(e) {

    e.nodeCount = Object.keys(e.data.nodes).length;

    return e;
  };

  var onGetExecutions = function(res) {

    H.clean('#executions tbody');

    var es = res.data._embedded['flack:executions'];
    if (es.length < 1) {
      H.elt('#executions tbody').appendChild(templates.noExecutions());
    }
    else {
      es.forEach(function(e) {
        reworkExecution(e);
clog(e);
        H.elt('#executions tbody').appendChild(templates.execution(e));
      });
    }
  };

  var flash = function(level, message) {
    H.hide('.flash');
    var e = H.elt('#flash-' + level);
    e.textContent = message;
    H.unhide(e);
  };

  // public functions

  this.loadExecutions = function() {

    H.request('GET', 'executions', onGetExecutions);
  };

  this.init = function() {

    H.hide('.flash');

    H.on('form#launch', 'submit', launchSubmit);

    self.loadExecutions();
  };

  // done.

  return this;

}).apply({}); // end Flack

