const express = require("express");
const router = express.Router();
var obj = require("../models/airlines.model");

router.get("/", async (req, res) => {
  let page = req.query.page||0;
  let limit = req.query.limit||1000;
  result = await obj.getAirlines("", limit, page);
  return res.send(JSON.stringify(result));
});

router.get("/:airline", async (req, res) => {
  let page = req.query.page||0;
  let limit = req.query.limit||1000;
  var airline = req.params.airline;
  result = await obj.getAirlines(airline, limit, page);
  return res.send(JSON.stringify(result));
});

module.exports = router;
