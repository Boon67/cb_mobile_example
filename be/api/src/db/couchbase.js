//Couchbase Connection
const couchbase = require("couchbase");
var cluster = null;

async function init() {
  //Defaults
  uri=process.env.DB_URI + ":" + process.env.DB_PORT || "couchbase://localhost:8091"
  uid=process.env.DB_USER || "Administrator"
  pwd=process.env.DB_PASS || "password"

  cluster = await couchbase.connect(uri, {
    username: uid,
    password: pwd,
  });

  //bucket = cluster.bucket(process.env.DB_NAME);
  //collection = bucket.scope("inventory").collection("airline");
}

/** runQuery function excutes the query on the database
 * @param: {string} query Complete query string to be submitted to the database
 */
async function runQuery(query) {
  if (!cluster) await init();
  try {
    console.log(query)
    let result = await cluster.query(query);
    //console.log("Result:", result.rows);
    return result.rows;
  } catch (error) {
    console.error("Query failed: ", error);
    return error;
  }
}

module.exports = {
  runQuery,
};
