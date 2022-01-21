const db = require('../db/couchbase');
const joi = require("joi");

const airportSchema = {
	id: String,
  airportname: String,
  icao: String
};

async function getHotelsbyCity(city, limit, page) {
  var query = 'SELECT name, city, geo  FROM `travel-sample`.`inventory`.`hotel` WHERE LOWER(city) like LOWER("' + city + '%") LIMIT ' + limit + ' OFFSET ' + page;
  console.log(query)
  return await db.runQuery(query)
}

module.exports = {
  getHotelsbyCity
};