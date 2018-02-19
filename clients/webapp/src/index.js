import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import { createStore, applyMiddleware } from 'redux';
import username from './reducers/userReducer';

let middleware = applyMiddleware();

let store = createStore(username,middleware);

ReactDOM.render(
        <App store={store} />,
    document.getElementById('root'));


