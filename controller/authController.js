const { pool } = require('../database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

require('dotenv').config();

const secret_key = process.env.JWT_SECRET_KEY;
// let userid = 0;
// let rol = 0;
const configCookie = {
    maxAge: 15 * 60 * 1000,
    httpOnly: true,
    sameSite: 'lax',
    secure: true
};

async function login(req, res) {
    const { nomina, password } = req.body;
    let status;

    try{
        const result = await pool.query('CALL rh.sps_login($1, null);',[
            nomina
        ]);
        // console.log("Estatuseses", result.rows[0].v_estatus)
        status = result.rows[0].v_estatus;

        switch (status) {
            case 0: //No existe el usuario
                res.status(401).json({
                    "error": "No se encontro al usario en la BD",
                    "code": "USER_NOT_FOUND"
                });
                break;
            case 1: //Todo ok
                const result1 = await pool.query('select * from rh.fn_login($1)',[
                    nomina
                ]);
                const passwordMatch = await bcrypt.compare(password, result1.rows[0].hash);
                if(!passwordMatch){
                    res.status(401).json({
                        "error": "Credenciales invalidas",
                        "code": "INVALID_CREDENTIALS"
                    });
                }else{
                    // userid = result1.rows[0].nomina;
                    // username = result1.rows[0].username;
                    // nombre = result1.rows[0].nombre;
                    // departamento = result1.rows[0].departamento;
                    rol = result1.rows[0].rol;

                    const token = jwt.sign({nomina}, secret_key, { expiresIn: '1h' });

                    res.cookie('token', token, configCookie);
                    // res.cookie('nomina', userid, configCookie);
                    // res.cookie('rol', rol, configCookie);

                    res.status(200).json(result1.rows);
                }
                break;
            case 2: //Se necesita cambiar contraseña
                res.status(401).json({
                    "error": "Se necesita reestablecer contraseña",
                    "code": "REST_PASSWORD"
                });
                break;
        
            default:
                console.log("Problema: ",status);
                break;
        }
    }catch(err){
        console.error(err);
        res.status(500).json({
            'error': 'Error en la BD',
            'code': 'ERROR_UNDEFINED'
        })
    }
}

async function updatePassword(req, res) {
    try{
        const { nomina, password } = req.query;

        const new_hash = await bcrypt.hash(password, 10);

        const response = await pool.query('CALL rh.spu_change_password($1,$2,null)', [
            nomina, new_hash
        ]);

        if(response.rows[0].v_message == 1){
            res.status(204).json({
                'message': 'Se ha actualizado la contraseña',
                'code': 'REST_PASSWORD_SUCCESS'
            });
        } else{
            res.status(400).json({
                'message': 'Se necesita autorizar el reset de la contraseña',
                'code': 'REST_PASSWORD_FAIL'
            })
        }
    }catch(err){
        console.error(err);

    }
}

module.exports = {
    login,
    updatePassword
}