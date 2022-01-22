const db = require('../db/couchbase');
const joi = require("joi");
const dbname=process.env.DB_NAME;
const scope=process.env.DB_SCOPE;
const collection=process.env.COL_AIRLINES

const airlineSchema = {
	id: String,
  name: String,
  callsign: String,
  icao: String
};

async function getAirlines(name, limit, page) {
  var query = 'SELECT id, name, icao, callsign FROM `'+ dbname + '`.`'+ scope + '`.`'+ collection + '` where LOWER(name) like LOWER("' + name + '%") LIMIT ' + limit + ' OFFSET ' + page;
  return await db.runQuery(query)
}

module.exports = {  
  getAirlines
};