const express = require('express');
const userRoute = express.Router();

const userController = require('../controller/usuario_controller');
const authMiddleware = require('../middleware/authMiddleware')

userRoute.get('/usuario/:id', userController.searchUser);
userRoute.get('/menu/:id', userController.getMenu);
userRoute.get('/usuarios', authMiddleware.valiteSession, userController.getAllusers);
userRoute.get('/departamentos', userController.getAllDepartamentos);
userRoute.get('/puestos', userController.getAllPuestos);
userRoute.get('/roles', userController.getAllRoles);
userRoute.get('/usuariofull/:nomina', userController.getUserByID);

userRoute.post('/usuario', userController.createUser);
userRoute.put('/usuario/:id', userController.updateUser);
userRoute.delete('usuario/:id', userController.deleteUser);

module.exports = userRoute;