import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import { HashRouter as Router, Switch, Redirect, Route } from 'react-router-dom';
import { Provider } from 'react-redux';
import Home from './components/home';
import PropTypes from 'prop-types';

const App = ({ store }) => (
  <Provider store={store}>
    <Router>
      <Switch>
        <MuiThemeProvider>
          <Route exact path={"/"} component={Home} />
        </MuiThemeProvider>
      </Switch>
    </Router>
  </Provider>
)

App.propTypes = {
  store: PropTypes.object.isRequired
}

export default App;
