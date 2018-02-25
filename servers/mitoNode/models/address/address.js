'use strict';

class Address {
    constructor(userId, streetAddress1, streetAddress2, cityName, zipCode, stateName) {

        this.userId = userId

        this.streetAddress1 = streetAddress1

        this.streetAddress2 = streetAddress2

        this.cityName = cityName

        this.zipCode = int(zipCode)

        this.stateName = stateName
    }
}

module.exports = Address;