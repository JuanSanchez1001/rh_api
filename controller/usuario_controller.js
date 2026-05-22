/*
    Creado por Juan Sanchez
*/

const { pool } = require('../database');

async function searchUser(req, res) {
    try{
        const nomina = req.params.id;
        // console.log(nomina)
        const result = await pool.query('select * from rh.searchuser($1)',
            [nomina]
        )
        // console.log("Array", result.rows.length)
        if(result.rows.length == 0){
            res.status(400).json({
                    "error": "Usuario no encontrado",
                    "code": "USER_NOT_FOUND"
                }
            );
        }else {
            res.status(200).json(result.rows);
        }
    }catch(err){
        console.error("Hubo un error", err);
    }
}
async function getMenu(req, res) {
    try{
        const nomina = req.params.id;
        // const nomina = req.cookies.nomina;
        
        //console.log(nomina);
        const result = await pool.query('select * from rh.fn_getusermenu($1)',[
            nomina
        ]);
        res.status(200).json(result.rows);
    }catch(err){
        console.error(err);
        
    }
}

//Opciones de usuarios
async function createUser(req, res) {
    try{
        const { v_nomina, v_nombre, v_apepaterno, v_apematerno, v_genero, v_correo, v_edad, v_jefedirecto, v_rolidf, v_departament, v_username, v_cargo } = req.body;
        const response = await pool.query('CALL rh.spi_create_user($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)', [
            v_nomina, v_nombre, v_apepaterno, v_apematerno, v_genero, v_correo, v_edad, v_jefedirecto, v_rolidf, v_departament, v_username, v_cargo
        ]);
        res.status(201).json({
            "message": "",
            "code": ""
        });
    }catch(err){
        console.error(err)
    }
}
async function updateUser(req, res) {
    try{
        const v_nomina = req.params.id;
        const { v_nombre, v_apepaterno, v_apematerno, v_genero, v_correo, v_edad, v_jefedirecto, v_rolidf, v_departament, v_username, v_cargo } = req.body;

        const response = await pool.query('CALL rh.spu_editeuser($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12);', [
            v_nombre, v_apepaterno, v_apematerno, v_genero, v_correo, v_edad, v_jefedirecto, v_rolidf, v_departament, v_username, v_cargo
        ]);
        res.status(201).json({
            "message": "",
            "code": ""
        });
    }catch(err){
        console.error(err)
    }
}
async function deleteUser(req, res) {
    try{
        const userid = req.params.id;
        const response = await pool.query('CALL rh.spd_deleteuser($1)', [
            userid
        ]);
        res.status(201).json({
            "message": "",
            "code": ""
        });
    }catch(err){
        console.error(err)
    }
}
module.exports = {
    searchUser,
    getMenu,
    createUser,
    updateUser,
    deleteUser
}