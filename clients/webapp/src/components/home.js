import React from 'react';
import { getUsername } from './../actions/updateProfile';
import FlatButton from 'material-ui/FlatButton';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

// @connect((store) => {
//     return {
//         user: store.user.username
//     };
// })
class Home extends React.Component {
    constructor(props) {
        super(props);
        //this.store = this.props.store;
    }
    handleSubmit = () => {
        this.props.getUsername('sneak');
    }
    render() {
        return (
            <div>
                <header>
                    <h1>{this.props.username}</h1>
                </header>
                <main>
                    <FlatButton backgroundColor='green' label='Get User Information' onClick={this.handleSubmit.bind(this)} />
                </main>
            </div>
        )
    }
}

const mapStateToProps = state => ({
    username: 'none'
})

const mapDispatchToProps = dispatch => {
    return {
        getUsername: name => dispatch(getUsername(name))
    }
};

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(Home)
// export default connect()(Home);
