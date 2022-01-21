const express = require("express");
const router = express.Router();
var obj = require("../models/hotels.model");

router.get("/", async (req, res) => {
  let page = req.query.page||0;
  let limit = req.query.limit||1000;
  result = await obj.getHotelsbyCity("", limit, page);
  return res.send(JSON.stringify(result));
});

router.get("/:city", async (req, res) => {
  let page = req.query.page||0;
  let limit = req.query.limit||1000;
  var city = req.params.city;
  result = await obj.getHotelsbyCity(city, limit, page);
  return res.send(JSON.stringify(result));
});

module.exports = router;
