// https://github.com/angular/material/blob/master/src/components/input/input.js#L323

angular.module('applicationFormt')
.directive('mdMaxwords', ['$animate', function($animate) {
  return {
    restrict: 'A',
    require: ['ngModel', '^mdInputContainer'],
    link: postLink
  };

  function postLink(scope, element, attr, ctrls) {
    var maxwords;
    var ngModelCtrl = ctrls[0];
    var containerCtrl = ctrls[1];
    var charCountEl = angular.element('<div class="md-char-counter">');
    var input = angular.element(containerCtrl.element[0].querySelector('[md-maxwords]'));

    // Stop model from trimming. This makes it so whitespace
    // over the maxwords still counts as invalid.
    attr.$set('ngTrim', 'false');

    var ngMessagesSelectors = [
      'ng-messages',
      'data-ng-messages',
      'x-ng-messages',
      '[ng-messages]',
      '[data-ng-messages]',
      '[x-ng-messages]'
    ];

    var ngMessages = containerCtrl.element[0].querySelector(ngMessagesSelectors.join(','));

    // If we have an ngMessages container, put the counter at the top; otherwise, put it after the
    // input so it will be positioned properly in the SCSS
    if (ngMessages) {
      angular.element(ngMessages).prepend(charCountEl);
    } else {
      input.after(charCountEl);
    }

    ngModelCtrl.$formatters.push(renderCharCount);
    ngModelCtrl.$viewChangeListeners.push(renderCharCount);
    element.on('input keydown keyup', function() {
      renderCharCount(); //make sure it's called with no args
    });

    scope.$watch(attr.mdMaxwords, function(value) {
      maxwords = value;
      if (angular.isNumber(value) && value > 0) {
        if (!charCountEl.parent().length) {
          $animate.enter(charCountEl, containerCtrl.element, input);
        }
        renderCharCount();
      } else {
        $animate.leave(charCountEl);
      }
    });

    // http://jsfiddle.net/deepumohanp/jZeKu/
    var regex = /\s+/gi;
    function wordCount(value) {
      return value.trim().replace(regex, ' ').split(' ').length;
    }

    ngModelCtrl.$validators['md-maxwords'] = function(modelValue, viewValue) {
      if (!angular.isNumber(maxwords) || maxwords < 0) {
        return true;
      }
      return wordCount( modelValue || element.val() || viewValue || '' ) <= maxwords;
    };

    function renderCharCount(value) {
      // Force the value into a string since it may be a number,
      // which does not have a length property.
      charCountEl.text(wordCount(String(element.val() || value || '')) + '/' + maxwords + ' words');
      return value;
    }
  }
}]);
