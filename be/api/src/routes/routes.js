const express = require('express');
const router = express.Router();
const airport = require('./hotels.route')
const airline = require('./airlines.route')
const hotel = require('./hotels.route')
const route = require('./routes.route')

// generic route handler
const genericHandler = (req, res, next) => {
  res.json({
    status: 'success',
    data: req.body
  });
};

// Home page route.
router.get('/', function (req, res) {
    res.send('Nothing to see here');
  })

// Airports page route.
router.use('/airports', airport);

// Airlines page route.
router.use('/airlines', airline);

// Hotels page route.
router.use('/hotels', hotel);

// Routes page route.
router.use('/routes', route);

module.exports = router;