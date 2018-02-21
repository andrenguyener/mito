/*
To alleviate the need of importing individual reducer to multiple files,
simply import them all here and perform combineReducers() on all the reducers
and export default one large directory of all reducers. 
This way, only one import is needed to be called at store.js
*/

// import {combineReducers} from 'redux';
import user from "./userReducer";

// export default combineReducers({
//   tweets,
//   user,
// })

export default user;