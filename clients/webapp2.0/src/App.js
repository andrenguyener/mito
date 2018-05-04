import React, { Component } from 'react';
import { Router, Route, HashRouter } from "react-router-dom";
import Home from './Home';
import About from './About';
import Business from './Business';
import Security from './Security';
import Navbar from './components/navbar';
// import './App.css';

class App extends Component {
    render() {
        return (
            <div className="App">
                <HashRouter>
                    {/* <TransitionGroup component="main" className="page-main">
                        <CSSTransition key={currentKey} timeout={timeout} classNames="fade" appear> */}
                    <div className="page-main-inner">
                        <Navbar />
                        {/* <Switch location={window.location}> */}
                        {/* <Route exact path="/" component={Home} />
            <Route path="/about" component={About} />
            <Route path="/projects" component={Projects} />
            <Route path="/contact" component={Contact} /> */}

                        {/* </Switch> */}
                        <Route exact path="/" component={Home} />
                        <Route path="/about" component={About} />
                        <Route path="/business" component={Business} />
                        <Route path="/security" component={Security} />
                    </div>
                    {/* </CSSTransition>
                    </TransitionGroup> */}
                </HashRouter>
            </div>
        );
    }
}

export default App;
