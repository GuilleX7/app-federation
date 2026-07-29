chunkLoadingGlobal.callbacks = chunkLoadingGlobal.callbacks || [];
chunkLoadingGlobal.attachers = chunkLoadingGlobal.attachers || [];
const ownJsonpCallback = webpackJsonpCallback.bind(null, 0);
var isFirstJsonpLoader = !chunkLoadingGlobal.originalPush;
if (!chunkLoadingGlobal.originalPush) {
  chunkLoadingGlobal.originalPush = chunkLoadingGlobal.push;
}

__webpack_require__.jsonp_loader_attach = function() {
  chunkLoadingGlobal.push = function (data) {
    chunkLoadingGlobal.originalPush(data);
    chunkLoadingGlobal.callbacks.forEach((callback) => callback(data));
  }
  if (chunkLoadingGlobal.attachers) {
    const ownAttacherIdx = chunkLoadingGlobal.attachers.indexOf(__webpack_require__.jsonp_loader_attach);
    if (ownAttacherIdx !== -1) {
      chunkLoadingGlobal.attachers.splice(ownAttacherIdx, 1);
    }
  }
}

__webpack_require__.jsonp_loader_detach = function() {
  const ownCallbackIdx = chunkLoadingGlobal.callbacks.indexOf(ownJsonpCallback);
  if (ownCallbackIdx !== -1) {
    chunkLoadingGlobal.callbacks.splice(ownCallbackIdx, 1);
  }
  chunkLoadingGlobal.push = chunkLoadingGlobal.originalPush;
  if (chunkLoadingGlobal.attachers && chunkLoadingGlobal.attachers[0]) {
    chunkLoadingGlobal.attachers[0]();
  }
}

if (isFirstJsonpLoader) {
  __webpack_require__.jsonp_loader_attach(chunkLoadingGlobal);
} else {
  chunkLoadingGlobal.attachers.push(__webpack_require__.jsonp_loader_attach);
}

chunkLoadingGlobal.callbacks.push(ownJsonpCallback);
chunkLoadingGlobal.forEach(ownJsonpCallback);