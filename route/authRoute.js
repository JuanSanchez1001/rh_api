const express = require('express');
const authRoute = express.Router();

const auth = require('../controller/authController');

authRoute.post('/login', auth.login);

module.exports = authRoute;