const db = require('../db/couchbase');
const joi = require("joi");

const airportSchema = {
	id: String,
  airportname: String,
  icao: String
};

async function getAirportsbyCity(city, limit, page) {
  var query = 'SELECT id, type, airportname, icao FROM `travel-sample`.`inventory`.`airport` WHERE LOWER(city) like LOWER("' + city + '%") LIMIT ' + limit + ' OFFSET ' + page;
  console.log(query)
  return await db.runQuery(query)
}

module.exports = {
  getAirportsbyCity
};