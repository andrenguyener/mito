import React from 'react';
import { NavLink } from 'react-router-dom';
import {
    Menu,
    Responsive
} from "semantic-ui-react";




class Navbar extends React.Component {

    constructor(props) {
        super(props)
        this.state = {
            menuOpen: false,
            toggle: false
        }
    }

    handleStateChange(state) {
        this.setState({ menuOpen: state.isOpen })
    }

    closeMenu() {
        this.setState({ menuOpen: false, toggle: false })
    }



    render() {
        return (
            <div id="navigation-bar">
                <div id="logo">
                    <NavLink exact to="/" activeClassName="selected"  ><p>Mito</p></NavLink>
                </div>
                <Responsive minWidth={Responsive.onlyTablet.minWidth}>
                    <Menu pointing id="navigation-desktop" floated="right">
                        <NavLink to="/about" activeClassName="selected" >How Mito Works</NavLink>
                        <NavLink to="/business" activeClassName="selected">Business</NavLink>
                        <NavLink to="/security" activeClassName="selected">Security</NavLink>
                    </Menu>
                </Responsive>

            </div>
        );

    }
}



export default Navbar;
