"use strict";

exports.fetch = function(url) {
    return function(init) {
        return function(success, error) {
            window.fetch(url, init).then(success, error);
        }
    }
}
