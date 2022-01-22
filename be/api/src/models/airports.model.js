const db = require('../db/couchbase');
const joi = require("joi");
const dbname=process.env.DB_NAME;
const scope=process.env.DB_SCOPE;
const collection=process.env.COL_AIRPORTS

const airportSchema = {
	id: String,
  airportname: String,
  icao: String
};

async function getAirportsbyCity(city, limit, page) {
  var query = 'SELECT id, type, airportname, icao FROM `'+ dbname + '`.`'+ scope + '`.`'+ collection + '` WHERE LOWER(city) like LOWER("' + city + '%") LIMIT ' + limit + ' OFFSET ' + page;
  console.log(query)
  return await db.runQuery(query)
}

module.exports = {
  getAirportsbyCity
};