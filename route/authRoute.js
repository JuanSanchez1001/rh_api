const express = require('express');
const authRoute = express.Router();

const auth = require('../controller/authController');
const autMiddleware = require('../middleware/authMiddleware')

authRoute.post('/login', autMiddleware.validateLoginData, auth.login);
authRoute.put('/reset_password', autMiddleware.validateChangePassword, auth.updatePassword);

module.exports = authRoute;