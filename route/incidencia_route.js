const express = require('express');
const incidenciaRoute = express.Router();

const incidenciaController = require('../controller/incidencia_controller');
const incidenciaMiddleware = require('../middleware/incidencia_middleware');
const authMiddleware = require('../middleware/authMiddleware');

incidenciaRoute.get('/motivos', incidenciaController.getMotivos);
// incidenciaRoute.get('/incidencias', incidenciaController.getAllIncidencias);
incidenciaRoute.get('/salidas', incidenciaController.getAllSalidas); //Se usa query
incidenciaRoute.get('/ausencias', incidenciaController.getAllAusencias); //Se usa query
incidenciaRoute.get('/salida/:id', incidenciaController.getSalidaByID);
incidenciaRoute.get('/ausencia/:id', incidenciaController.getAusenciaByID);
incidenciaRoute.get('/incidencia/:id', incidenciaController.getIncidenciaByid);


incidenciaRoute.post('/incidencia_salida',incidenciaMiddleware.vaidateIncidenciaSalida, incidenciaController.createIncidenciaSalida);
incidenciaRoute.post('/incidencia_ausencia', incidenciaController.createIncidenciaAusencia);

incidenciaRoute.put('/ausencia/:id',/*authMiddleware.valiteSession,*/ incidenciaController.updateAusencia);
incidenciaRoute.put('/salida/:id',/*authMiddleware.valiteSession,*/ incidenciaController.updateSalida);

module.exports = incidenciaRoute;