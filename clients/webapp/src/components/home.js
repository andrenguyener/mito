import React from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import { getUsername } from '../actions/userActions';
import FlatButton from 'material-ui/FlatButton';

/*
mapStateToProps() allows for isolations of state (declaration of state can be found in corresponding reducer) 
and pass those state as properties to the component.
With this, state can be accessible via this.props  
 */
function mapStateToProps(state) {
    return { user: state.user };
}

/*
mapDispatchToProps() allows for embedding redux actions to props for dispatching.
bindActionCreators() bind whatever redux actions object passed in the first @param to a dispatcher
With this, to dispatch a redux action, simply call this.props.nameOfAction()
 */
function mapDispatchToProps(dispatch) {
    return bindActionCreators({getUsername}, dispatch);
}


class Home extends React.Component {   
    handleSubmit = () => {
        this.props.getUsername('sneak');
    }
    render() {
        return (
            <div>
                <header>
                    <h1>{this.props.user.username}</h1>
                </header>
                <main>
                    <FlatButton backgroundColor='green' label='Get User Information' onClick={this.handleSubmit.bind(this)} />
                </main>
            </div>
        )
    }
}

export default connect(mapStateToProps, mapDispatchToProps)(Home);
