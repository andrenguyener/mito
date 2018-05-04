import React from 'react';
import ReactDOM from 'react-dom';
import './styles/normalize.css'
import 'semantic-ui-css/semantic.min.css';
import './styles/app.css';
import App from './App';
import registerServiceWorker from './registerServiceWorker';

ReactDOM.render(<App />, document.getElementById('root'));
registerServiceWorker();
