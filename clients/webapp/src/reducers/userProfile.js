import {GET_USERNAME,FETCH_USER} from './../actions/updateProfile';
import {Home} from './../components/home';

const username = (state = {username: 'not logged in'}, action) => {
    switch(action.type) {
        case GET_USERNAME : {
            state = {...state, username: action.payload}
        }
        case FETCH_USER: {
            state = {...state, userObject: action.payload}
        }
    }
    return state;
};

export default username;