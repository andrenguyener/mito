import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import Root from './App';
import { createStore } from 'redux';
import profile from './reducers/userProfile';

let store = createStore(profile);

ReactDOM.render(
        <Root store={store} />,
    document.getElementById('root'));


