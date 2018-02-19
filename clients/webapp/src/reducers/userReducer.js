import {GET_USERNAME} from './../actions/updateProfile';

const initialState = {
    username: 'empty',
    firstName: '',
    lastName: ''
}

export default function username(state = initialState, action) {
    switch(action.type) {
        case GET_USERNAME : {
            return {...state, username: action.payload}
        }
        // case FETCH_USER: {
        //     state = {...state, userObject: action.payload}
        // }
    }
    return state;
};
