import React from 'react';
import { getUsername } from './../actions/updateProfile';
import FlatButton from 'material-ui/FlatButton';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

function mapStateToProps(state) {
    return { user: state.username };
}

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
                    <h1>{this.props.user}</h1>
                </header>
                <main>
                    <FlatButton backgroundColor='green' label='Get User Information' onClick={this.handleSubmit.bind(this)} />
                </main>
            </div>
        )
    }
}

export default connect(mapStateToProps, mapDispatchToProps)(Home);
