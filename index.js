const express = require('express');
const cookiesParser = require('cookie-parser');

const userRoute = require('./route/user_route');
const incidenciaRoute = require('./route/incidencia_route');
const userAuth = require('./route/authRoute');

require('dotenv').config();

const cors = require('cors');

const app = express();
const PORT = process.env.PORT;

app.use(express.json()); // Para que entienda json
app.use(cookiesParser()); //set cookies

app.use(cors({ // Debe de cambiar a la ip donde se levante todote
    origin: 'http://localhost:5173',
    credentials: true
})); 

//rutas
app.use('/rh', userAuth);
app.use('/rh/usuarios', userRoute);
app.use('/rh/incidencia', incidenciaRoute);

//Levantar el servidor
const runServer = () => {
    return new Promise((resolve, reject) => {
        const server = app.listen(PORT, '0.0.0.0', () => {
            resolve(server);
        });
        server.on('error', (err) => {
            reject(err);
        });
    });
};

async function serverON(){
    try{
        await runServer();
        console.log("El servidor se levanto exitosamente. :D");
    }catch (error){
        console.error("Hubo un problema");
        console.error(error);
        
        process.exit(1);
    }
}
serverON();