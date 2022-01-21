const express = require("express");
const router = express.Router();
var obj = require("../models/route.model");

router.get("/", async (req, res) => {
  res.send({})
});

router.get("/:orig/:dest", async (req, res) => {
  let page = req.query.page||0;
  let limit = req.query.limit||10;
  var orig = req.params.orig;
  var dest = req.params.dest;
  result = await obj.getRoutesbyOrigDest(orig, dest, limit, page);
  return res.send(JSON.stringify(result));
});

module.exports = router;
