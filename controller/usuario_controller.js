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
    console.log(req.body);
    try{
        const { nomina, nombre, ape_paterno, ape_materno, genero, correo, edad, username, superid, departamento, puesto, rol } = req.body;
        const response = await pool.query('CALL rh.spi_create_user($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)', [
            nomina, nombre, ape_paterno, ape_materno, genero, correo, edad, username, superid, departamento, puesto, rol
        ]);
        res.status(201).json({
            "message": "Usuario creado con exito",
            "code": "USER_CREATED"
        });
    }catch(err){
        console.error(err)
    }
}
async function updateUser(req, res) {
    try{
        const nomina = req.params.nomina;
        const { nombre, ape_paterno, ape_materno, genero, correo, edad, username, superid, departamento, puesto, rol  } = req.body;

        const response = await pool.query('CALL rh.spu_update_user($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12);', [
            nomina, nombre, ape_paterno, ape_materno, genero, correo, edad, username, superid, departamento, puesto, rol
        ]);
        res.status(201).json({
            "message": "Usuario actualizado con éxito",
            "code": "USER_MODIFIED"
        });
    }catch(err){
        console.error(err)
    }
}
async function deleteUser(req, res) {
    try{
        const nomina = req.params.nomina;
        const response = await pool.query('CALL rh.spd_deleteuser($1)', [
            nomina
        ]);
        res.status(201).json({
            "message": "Se elimino el usuario",
            "code": "USER_DROPPED"
        });
    }catch(err){
        console.error(err)
    }
}
async function getAllusers(req, res) {
    try{
        const response = await pool.query("select * from rh.fn_getallusers()");

        res.status(200).json(response.rows);
    }catch(err){
        console.error(err);
    }
}

//Info usuario
async function getAllDepartamentos(req, res) {
    try{
        const response = await pool.query('select * from rh.fn_getdepartamentos()');

        res.status(200).json(response.rows);
    }catch(err){
        console.error(err)
    }
}
async function getAllPuestos(req, res) {
    try{
        const response = await pool.query('select * from rh.fn_getpuestos()');
        res.status(200).json(response.rows);
    }catch(err){
        console.error(err)
    }
}
async function getAllRoles(req, res) {
    try{
        const response = await pool.query('select * from rh.fn_getroles()');
        res.status(200).json(response.rows);
    }catch(err){
        console.error(err)
    }
}
async function getUserByID(req, res) {
    try{
        const nomina = req.params.nomina;
        // console.log(nomina)
        const result = await pool.query('select * from rh.fn_getuserbyid($1);',[
            nomina
        ]);
        res.status(200).json(result.rows);
    }catch(err){
        console.error(err)
    }
}
async function enableResetPassword(req, res) {
    try{
        const nomina = req.params.nomina;
        const result = await pool.query('CALL rh.spu_enable_reset_pass($1)', [
            nomina
        ]);
        res.status(201).json({
            "message": "El usuario puede actualizar su contraseña",
            "code": "USER_MODIFIED"
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
    deleteUser,
    getAllusers,
    getAllDepartamentos,
    getAllPuestos,
    getAllRoles,
    getUserByID,
    enableResetPassword
}