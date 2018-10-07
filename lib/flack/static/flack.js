
window.clog = console.log;
window.cerr = console.error;


var Flack = (function() {

  "use strict";

  var self = this;

  // protected functions

  var onPostMessage = function(res) {

clog(res);
  };

  var launchSubmit = function(ev) {

    ev.preventDefault();

    var j = {};
    j.point = 'launch';
    j.domain = H.elt('form#launch [name="domain"]').value;
    j.tree = H.elt('form#launch [name="tree"]').value;
clog(j);

    H.request('POST', 'message', j, onPostMessage);

    return false;
  };

  var onGetExecutions = function(res) {

    H.clean('#executions');

clog(res);
clog(res.status);
//clog(res.data._embedded);
    var es = res.data._embedded['flack:executions'];
clog(es);
    if (es.length < 1) {
      H.elt('#executions').appendChild(templates.noExecutions());
    }
    else {
// TODO
    }
  };

  // public functions

  this.loadExecutions = function() {

    H.request('GET', 'executions', onGetExecutions);
  };

  this.init = function() {

    H.on('form#launch', 'submit', launchSubmit);

    self.loadExecutions();
  };

  // done.

  return this;

}).apply({}); // end Flack

