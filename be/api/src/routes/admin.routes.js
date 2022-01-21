const express = require('express');
const checkAuth = require('../middleware/checkAuth.middleware');
const adminControllers = require('../Controllers/admin.controllers');
const router = express.Router();

router.post('/signup', adminControllers.adminRegister);
router.post('/login', adminControllers.adminLogin);
router.get('/profile', checkAuth, adminControllers.getMe);

module.exports = router