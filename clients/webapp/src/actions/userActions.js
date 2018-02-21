/*
userActions give definition what each action will take in as parameter (if needed), which may be use
as payloads for reducers.
type: ACTION_NAME
payload: data (can be an object, or an array, or a string, etc.)
Those payloads are data that reducers can use to update states.
*/

// export var fetchUser = (username) => {
//     return {
//         type: FETCH_USER,
//         username
//     }
// };

export function getUsername(username) {
    return {
        type: 'GET_USERNAME',
        payload: username,
    }
}
