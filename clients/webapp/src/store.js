import { applyMiddleware, createStore } from "redux";
// import logger from "redux-logger";
// import thunk from "redux-thunk";
// import promise from "redux-promise-middleware";

import reducer from "./reducers";

// let middleware = applyMiddleware(promise(), thunk, logger());

// put middleware in createStore() for implementation
export default createStore(reducer)