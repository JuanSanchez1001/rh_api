
const { pool } = require('../database');

async function createIncidenciaSalida(req, res) {
    const { nomina, nombre,auto, placa, motivo, acompanantesQTY, tel, regresa, hora_salida, hora_regreso, lugar, descripcion, acompanante1, acompanante2, acompanante3, acompanante4, acompanante5 } = req.body;
    try{
            const result = await pool.query("CALL rh.spi_solicitud_salida($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)", [
                nomina, auto, placa, motivo, acompanantesQTY, tel, regresa, hora_salida, hora_regreso, lugar, descripcion, acompanante1, acompanante2, acompanante3, acompanante4, acompanante5
            ]);
            //Envio de correo
            const query1 = await pool.query("CALL rh.sps_getMailData($1,null)",[nomina]);
            const listEmails = query1.rows[0].v_mails;
            let body = JSON.stringify({
                    to: listEmails,
                    nomina: nomina,
                    nombre: nombre,
                    tipoIncidencia: "Salida de planta"
            });
            await fetch('http://localhost:3000/sendMail/crear_incidencia', { //Peticion para envio de correo
                method: "POST",
                body: body,
                headers: {
                    "Content-Type": "application/json"
                }
            });

            res.status(200).json({
                'message': 'Se levanto la incidencia'
                // 'estado': '200'
            });

    }catch (err){
        console.error(err);
    }
}
async function createIncidenciaAusencia(req, res){
    try{
        // console.log(req.body);
        const { nomina, nombre, motivo, vacacionesFlag, telefono, diasQTY, fecha_ini, fecha_fin, descripcion } = req.body;
        const result = await pool.query("CALL rh.spi_solicitud_ausencia($1,$2,$3,$4,$5,$6,$7,$8)", [
            nomina, motivo, vacacionesFlag, telefono, diasQTY, fecha_ini, fecha_fin, descripcion
        ]);
        const query1 = await pool.query("CALL rh.sps_getMailData($1,null)",[nomina]);
            const listEmails = query1.rows[0].v_mails;
            // console.log("mails",listEmails);
            let body = JSON.stringify({
                    to: listEmails,
                    nomina: nomina,
                    nombre: nombre,
                    tipoIncidencia: "Ausencia"
            });
            // console.log("body",body)
            await fetch('http://localhost:3000/sendMail/crear_incidencia', {
                method: "POST",
                body: body,
                headers: {
                    "Content-Type": "application/json"
                }
            });
        res.status(201).json({
            'message': 'La incidencia se creo correctamente'
            //id: result.rows[0].id -> y agregas un returningo como el de proc para regresar el id que se creo. Posibles mejoras 7u7
        })
    }catch(err){
        console.error(err)
    }
}
async function getMotivos(req, res) {
    try{
        // console.log("peticion: ", req.query);
        const {motivoidf} = req.query;
        const result = await pool.query("select * from rh.fn_getmotivos($1);",[ motivoidf ]);

        res.status(200).json(result.rows);
    }catch(err){
        console.log(err);
    }
}
//Obtener incidencias
async function getAllSalidas(req, res) {
    // console.log("cookie",req.cookies.token);
    const {userid} = req.query;
    try{
        const result = await pool.query("select * from rh.fn_gettablasalidas($1);", [
            userid
        ]);
        res.status(200).json(result.rows);
    }catch(err){
        console.error(err)
    }
}
async function getAllAusencias(req, res) {
    try{
        const {userid} = req.query;
        const result = await pool.query("select * from rh.fn_gettablaausencias($1);", [
            userid
        ]);
        res.status(200).json(result.rows);
    }catch(err){
        console.error(err)
    }
}
async function getAusenciaByID(req, res) {
    try{
        const v_id = req.params.id;
        console.log(v_id);
        const result = await pool.query("select * from rh.fn_getausenciabyid($1);",[
            v_id
        ]);
        res.status(200).json(result.rows);
    }catch(err){
        console.error(err)
    }
}
async function getSalidaByID(req, res) {
    try{
        const v_id = req.params.id;
        console.log(v_id);
        const result = await pool.query("select * from rh.fn_getsalidabyid($1)",[
            v_id
        ]);
        res.status(200).json(result.rows);
    }catch(err){
        console.error(err)
    }
}
async function getAllIncidencias(req, res) {
    try{
        // console.log(req.cookies.token);
        const result = await pool.query("select * from rh.fn_getincidencias();");
        res.status(200).json(result.rows);
    }catch(err){
        console.error(err)
    }
}

async function getIncidenciaByid(req, res) {
    try{
        const id = req.params.id;
        const response = await pool.query("select * from rh.fn_getincidenciabyid($1);",[
            id
        ]);
        res.status(200).json(response.rows)
    }catch(err){
        console.error(err)
    }
}
//Actualizar incidencias
async function updateSalida(req, res) {
    try{
        const v_id = req.params.id;
        const { v_usermodify, v_autorizaflag, v_voboflag, v_goceflag, v_placas, v_horasalida, v_horaregreso, v_regresaflag, v_observaciones } = req.body;
        const result = await pool.query("CALL rh.spu_update_salida($1,$2,$3,$4,$5,$6,$7,$8,$9,$10);", [
            v_id, v_usermodify, v_autorizaflag, v_voboflag, v_goceflag, v_placas, v_horasalida, v_horaregreso, v_regresaflag, v_observaciones
        ]);
        res.status(200).json({
            "message": "",
            "code": ""
        })
    }catch(err){
        console.error(err);
    }
}
async function updateAusencia(req, res) {
    // console.log("Peticion", req.body);
    // console.log("Peticion", req.params.id);
    const v_id = req.params.id;
    const { v_usermodify, v_autorizaflag, v_voboflag, v_goceflag, v_vacacionesflag, v_fechaini, v_fechafin, v_diasqty,v_observaciones } = req.body;
    try{
        const result = await pool.query("CALL rh.spu_update_ausencia($1,$2,$3,$4,$5,$6,$7,$8,$9,$10);",[
            v_id, v_usermodify, v_autorizaflag, v_voboflag, v_goceflag, v_vacacionesflag, v_fechaini, v_fechafin, v_diasqty,v_observaciones
        ]);
        res.status(200).json({
            "message": "",
            "code": ""
        })
    }catch(err){
        console.error(err);
    }
}
//Borrar incidencia
async function deleteIncidencia(req, res) {
    const v_id = req.params.id;
    try{
        const result = await pool.query("CALL rh.spd_deleteincidenciabyid($1)", [
            v_id
        ]);
        res.status(200).json({
            "message": "",
            "code": ""
        })
    }catch(err){
        console.log(err)
    }
}
module.exports = {
    createIncidenciaSalida,
    createIncidenciaAusencia,
    getMotivos,
    getAllSalidas,
    getAllAusencias,
    getIncidenciaByid,
    getAusenciaByID,
    getSalidaByID,
    updateSalida,
    updateAusencia,
    deleteIncidencia
}