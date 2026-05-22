const express = require('express');
const userRoute = express.Router();

const userController = require('../controller/usuario_controller');

userRoute.get('/usuario/:id', userController.searchUser);
userRoute.get('/menu/:id', userController.getMenu);

userRoute.post('/usuario', userController.createUser);
userRoute.put('/usuario/:id', userController.updateUser);
userRoute.delete('usuario/:id', userController.deleteUser);

module.exports = userRoute;