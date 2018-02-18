export const FETCH_USER = 'FETCH_USER';
export const GET_USERNAME = 'GET_USERNAME';

// export var fetchUser = (username) => {
//     return {
//         type: FETCH_USER,
//         username
//     }
// };

export var getUsername = (username) => {
    return {
        type: GET_USERNAME,
        username
    }
}
