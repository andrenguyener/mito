'use strict';

class Address {
    constructor(userId, streetAddress1, streetAddress2, cityName, zipCode, stateName, aliasName) {

        this.userId = userId

        this.streetAddress1 = streetAddress1

        this.streetAddress2 = streetAddress2

        this.cityName = cityName

        this.zipCode = zipCode

        this.stateName = stateName

        this.aliasName = aliasName
    }
}

module.exports = Address;