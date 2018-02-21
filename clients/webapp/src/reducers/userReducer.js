/*
userReducer includes all functions relevant to retreive/modifying/deleting/loading
user data (or payload defined in Actions).
Each case determine how states are being updated, which give data access to components and 
to avoid immutability, the function will always return a new object
*/

let initialState = {
    user: {
        username: '',
        firstName: '',
        lastName: ''
    }

}

export default function reducer(state = initialState, action) {
    switch (action.type) {
        case 'GET_USERNAME': {
            return { ...state, 
                user: {...state.user, username: action.payload }};
        }
        case 'FETCH_USER': {
            return {...state, userObject: action.payload};
        }
        /* no default */
    }
    return state;
};
