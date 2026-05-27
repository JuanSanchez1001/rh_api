const express = require('express');
const authRoute = express.Router();

const auth = require('../controller/authController');

authRoute.post('/login', auth.login);
authRoute.put('/reset_password', auth.updatePassword);

module.exports = authRoute;