const express = require('express');
const reporteRoute = express.Router();

const reporteController = require('../controller/reportes_controller');
// const authController = require('../controller/authController');

reporteRoute.get('/incidencias', reporteController.getReport);
reporteRoute.get('/incidencias/excel', reporteController.getExcelReport);
reporteRoute.get('/vigilancia', reporteController.getReporteVigilancia);

module.exports = reporteRoute;