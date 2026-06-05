const express = require('express');
const reporteRoute = express.Router();

const reporteController = require('../controller/reportes_controller');
// const authController = require('../controller/authController');

reporteRoute.get('/rh', reporteController.getReport);

module.exports = reporteRoute;