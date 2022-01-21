const db = require('../db/couchbase');
const joi = require("joi");

const routeSchema = {
	id: String,
  airportname: String,
  icao: String
};

async function getRoutesbyOrigDest(orig, dest, limit, page) {
  var query = 'SELECT airline, sourceairport, equipment, destinationairport, schedule, stops FROM `travel-sample`.`inventory`.`route` where LOWER(sourceairport)=LOWER("' + orig +'") AND LOWER(destinationairport)=LOWER("' + dest + '")  LIMIT ' + limit + ' OFFSET ' + page;
  console.log(query)
  return await db.runQuery(query)
}

module.exports = {
  getRoutesbyOrigDest
};