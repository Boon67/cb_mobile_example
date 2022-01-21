const db = require('../db/couchbase');
const joi = require("joi");

const airlineSchema = {
	id: String,
  name: String,
  callsign: String,
  icao: String
};

async function getAirlines(name, limit, page) {
  var query = 'SELECT id, name, icao, callsign FROM `travel-sample`.`inventory`.`airline` where LOWER(name) like LOWER("' + name + '%") LIMIT ' + limit + ' OFFSET ' + page;
  return await db.runQuery(query)
}

module.exports = {  
  getAirlines
};